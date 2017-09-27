From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: [PATCH V2] r8152: add Linksys USB3GIGV1 id
Date: Wed, 27 Sep 2017 09:15:56 +0200
Message-ID: <1506496556.28482.3.camel@suse.com>
References: <20170926010925.114436-1-grundler@chromium.org>
         <CAD=FV=Uk=oPuF7LMhHPM_CTPNEa_G26R6Ce023pTNCCsyqts1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
        LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Doug Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Grant Grundler <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAD=FV=Uk=oPuF7LMhHPM_CTPNEa_G26R6Ce023pTNCCsyqts1Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Dienstag, den 26.09.2017, 08:19 -0700 schrieb Doug Anderson:
> 
> I know that for at least some of the adapters in the CDC Ethernet
> blacklist it was claimed that the CDC Ethernet support in the adapter
> was kinda broken anyway so the blacklist made sense.  ...but for the
> Linksys Gigabit adapter the CDC Ethernet driver seems to work OK, it's
> just not quite as full featured / efficient as the R8152 driver.
> 
> Is that not a concern?  I guess you could tell people in this
> situation that they simply need to enable the R8152 driver to get
> continued support for their Ethernet adapter?

Hi,

yes, it is a valid concern. An #ifdef will be needed.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
