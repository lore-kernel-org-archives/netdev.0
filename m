From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH net] net: cdc_ncm: workaround for missing CDC Union
Date: Tue, 22 Jan 2013 10:32:28 +0100
Message-ID: <3625170.qHSC1Z5vti@linux-5eaq.site>
References: <1358519147-10073-1-git-send-email-bjorn@mork.no> <2214944.HMNV73jJm5@linux-5eaq.site> <2AC7D4AD8BA1C640B4C60C61C8E520154A8EE17D8E@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Greg Suarez <gsuarez@smithmicro.com>
To: Alexey ORISHKO <alexey.orishko@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39469 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813Ab3AVJc1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 04:32:27 -0500
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520154A8EE17D8E@EXDCVYMBSTM006.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 21 January 2013 18:59:05 Alexey ORISHKO wrote:

> > > Either the FLAG_MULTI_PACKET minidriver will have already padded the
> > > buffer so that we do not hit (length % dev->maxpacket == 0), or we
> > > should choose one of the alternatives: ZLP or padding.
> > 
> > But we cannot simply call __skb_put for a complicated data frame.
> > Besides you may want the current behavior.
> > 
> 
> Specification says: 
> NCM/MBIM shall not send ZLP if buffer size is dwNtbOutMaxSize.

Hi,

one thing on a generic level, which I hope you don't take wrong, but I need
to make it clear. Usbnet is for every driver. What a spec says
or what the reality of implementations of that spec looks like, determine
what usbnet needs to support.

But what is not needed to implement that spec doesn't matter in deciding
what usbnet needs not support. Drivers may or may not need ZLPs.

	Regards
		Oliver
 
