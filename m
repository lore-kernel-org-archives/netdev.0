From: Abhishek Shah <abhishek.shah-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 2/3] net: ethernet: bgmac: Make IDM register space optional
Date: Tue, 18 Jul 2017 00:07:35 +0530
Message-ID: <CAKUFe6ad027MAg-A3XO7i1=c-Q623JqMPCKV_+Hi+ZpUojBn-Q@mail.gmail.com>
References: <1499972649-6200-1-git-send-email-abhishek.shah@broadcom.com>
 <1499972649-6200-3-git-send-email-abhishek.shah@broadcom.com> <CAC3K-4o=WRqBv_vTf7QGDYjWzMmVog=63ZbiHbHAuW7zJcsHFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        "open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE BINDINGS"
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        BCM Kernel Feedback <bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAC3K-4o=WRqBv_vTf7QGDYjWzMmVog=63ZbiHbHAuW7zJcsHFQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Jon,

> This also will need to be added to
> drivers/net/ethernet/broadcom/bgmac-bcma.c.  Otherwise, the driver
> will no longer work for those platforms.  Since this was already
> accepted, please push out a fix ASAP.
>
I do not see how the bcma driver [bgmac-bcma.c] will no longer work.
The whole idea behind introducing this  BGMAC_FEAT_IDM_MASK bit
was to keep bcma driver's functionality intact.

The BGMAC_FEAT_IDM_MASK bit is explicitly set by the bgmac-platform driver
and is unset inside the same if the idm register base is provided.

For BCMA driver case, I do not touch BGMAC_FEAT_IDM_MASK bit, i.e. it
is *not* set.
And if it is not set, each idm operation done in bgmac.c will take place.
Please explain if I am missing something here.


Regards,
Abhishek
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
