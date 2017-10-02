From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] rndis_host: support Novatel Verizon USB730L
Date: Mon, 02 Oct 2017 16:17:50 -0700 (PDT)
Message-ID: <20171002.161750.1123671129875495210.davem@davemloft.net>
References: <20170927213103.11987-1-aleksander@aleksander.es>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170927213103.11987-1-aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
Date: Wed, 27 Sep 2017 23:31:03 +0200

> I'm not sure if binding this logic to a specific vid:pid (1410:9030)
> would be more appropriate here, or if it's ok to just bind
> class/subclass/protocol (as in the activesync case).  Let me know
> what you think.

I don't have enough USB Networking knowledge to make a decision here.

Some things seem confusing.  For example, if we should be matching
USB_CLASS_MISC, subclass=4, protocol=1 for RNDIS over Ethernet, then
we why aren't we also matching USB_CLASS_MISC, subclass=4, protocol=2
for RNDIS over wireless and instead are matching "Remote RNDIS" in
the form of USB_CLASS_WIRELSS, subclass=1, protocol=3?

I really don't understand any of this magic :-)

So someone more knowledgable needs to review this.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
