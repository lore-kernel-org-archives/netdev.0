From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH 2/4] misc: xgene: Add base driver for APM X-Gene SoC
 Queue Manager/Traffic Manager
Date: Thu, 19 Dec 2013 20:24:26 -0800
Message-ID: <20131220042426.GA21726@kroah.com>
References: <1387507503-7565-1-git-send-email-rapatel@apm.com>
 <1387507503-7565-3-git-send-email-rapatel@apm.com>
 <20131220032133.GB32310@kroah.com>
 <CAN1v_PuBZHN85xTodfSZ-+H4Wdj0T8kSFUJB56KVj9xFH3--JQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org, Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAN1v_PuBZHN85xTodfSZ-+H4Wdj0T8kSFUJB56KVj9xFH3--JQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


A: Top-posting.
Q: What is the most annoying thing in e-mail?

http://daringfireball.net/2007/07/on_top

On Thu, Dec 19, 2013 at 07:41:13PM -0800, Ravi Patel wrote:
> There is no need to talk to this driver from userspace.
> It is a device which is used by other IO devices to communicate with each
> other, including CPU.
> For example, if CPU (software) wants to send a message to Ethernet HW (i.e.
> send packet),
> it used this driver to enqueue a message to Ethernet.
> In other direction, if Ethernet HW receives a packet, it uses QM/TM device to
> send message to
> CPU (software) to process packet.

So it's a "bus" type of thing, right?

My question of "why isn't this reflected in the driver model" still
stands.

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
