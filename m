From: Kristian Evensen <kristian.evensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] rndis_host: Set random MAC for ZTE MF910
Date: Thu, 14 Jul 2016 09:54:33 +0200
Message-ID: <CAKfDRXiP=LpNqPi5nSoMM2BK510edvCoatRWQhnQ8Z66N40_iw@mail.gmail.com>
References: <1468427945-11600-1-git-send-email-kristian.evensen@gmail.com> <87k2gpnpo5.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87k2gpnpo5.fsf-3F4PFWf5pNjpjLOzFPqGjWGXanvQGlWp@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Bj=C3=B8rn,

On Thu, Jul 14, 2016 at 12:23 AM, Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote=
:
>
> Or how about the more generic?:
>
>         if (bp[0] & 0x02)
>                 eth_hw_addr_random(net);
>         else
>                 ether_addr_copy(net->dev_addr, bp);
>
> That would catch similar screwups from other vendors too.

Great idea, thanks. After submitting the patch I found some other
devices with a similar bug, and there are probably even more out
there. I will update patch and resubmit.

-Kristian
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
