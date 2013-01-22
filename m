From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH net] net: cdc_ncm: workaround for missing CDC Union
Date: Tue, 22 Jan 2013 10:07:07 +0100
Message-ID: <1621221.QORYF6fjNM@linux-5eaq.site>
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
Received: from cantor2.suse.de ([195.135.220.15]:38118 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754064Ab3AVJHF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 04:07:05 -0500
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520154A8EE17D8E@EXDCVYMBSTM006.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 21 January 2013 18:59:05 Alexey ORISHKO wrote:
> Specification says: 
> NCM/MBIM shall not send ZLP if buffer size is dwNtbOutMaxSize.
> 
> The problem is: 
> dwNtbOutMaxSize value is negotiated between host and device NCM/MBIM
> entities and usbnet has no knowledge about it.
> 
> Adding one byte to make buffer looking like a short packet was most
> simple approach instead of inventing a way to communicate 
> dwNtbOutMaxSize to usbnet.
> 
> You could drop short packet approach if dwNtbOutMaxSize is provided
> to usbnet and decision is made accordingly to NCM/MBIM spec (with
> exception to faulty devices).

We could do that. Feel free to send a patch. ;-)

	Regards
		Oliver
