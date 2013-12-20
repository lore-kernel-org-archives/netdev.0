From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH 0/4] misc: xgene: Add support for APM X-Gene SoC Queue
 Manager/Traffic Manager
Date: Thu, 19 Dec 2013 19:40:04 -0800
Message-ID: <20131220034004.GA8160@kroah.com>
References: <1387507503-7565-1-git-send-email-rapatel@apm.com>
 <20131220032217.GC32310@kroah.com>
 <CAN1v_PsibDTwQ9_ZxRnBtJA46BPne6fTuS_9TddWPZt6ewwgQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org
To: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAN1v_PsibDTwQ9_ZxRnBtJA46BPne6fTuS_9TddWPZt6ewwgQQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


A: No.
Q: Should I include quotations after my reply?

http://daringfireball.net/2007/07/on_top

On Thu, Dec 19, 2013 at 07:27:35PM -0800, Ravi Patel wrote:
> APM X-Gene SoC Ethernet driver is planned to be submitted on Dec 20 2=
013.
> Ethernet driver will be using these exported API's from QMTM driver.

Please submit a user of the api as part of the series, otherwise we
can't evaluate if it's really the correct thing to do or not.

> The APM X-Gene SoC Ethernet driver is going to live in=A0drivers/net/=
ethernet/apm
> /xgene.

So this is a "bus"?  How is the ethernet device going to show up in
sysfs as a parent of what as this isn't part of the driver model?

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
