From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: Re: [PATCH] Add Linksys WCF11 to hostap driver
Date: Fri, 28 Dec 2007 23:14:49 -0500
Message-ID: <1198901689.2221.3.camel@dv>
References: <200712281416.59079.openembedded@haerwu.biz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jouni Malinen <j@w1.fi>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcin Juszkiewicz <openembedded-sbG99h22wavzs492ZWNkEA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200712281416.59079.openembedded-sbG99h22wavzs492ZWNkEA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello!

On Fri, 2007-12-28 at 14:16 +0100, Marcin Juszkiewicz wrote:

> +       PCMCIA_DEVICE_PROD_ID1234(
> +               "The Linksys Group, Inc.", "Wireless Network CF Card", "ISL37300P",
> +               "RevA",
> +               0xa5f472c2, 0x9c05598d, 0xc9049a39, 0x57a66194),

I would prefer that revisions are not used for card identification in
presence of the chip name.  It's not like RevB would need another driver
as long as "ISL37300P" is still a part of the PCMCIA ID.
PCMCIA_DEVICE_PROD_ID123 should be enough.

-- 
Regards,
Pavel Roskin
