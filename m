From: Oliver Neukum <oneukum@suse.de>
Subject: Re: usbnet: use_mem_cache to avoid GFP_ATOMIC
Date: Wed, 13 Mar 2013 09:14:17 +0100
Message-ID: <5882445.YVRAO0hhTt@linux-5eaq.site>
References: <1363114759.37226.YahooMailNeo@web126005.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Facix Booka <facixbooka@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52121 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750844Ab3CMINw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Mar 2013 04:13:52 -0400
In-Reply-To: <1363114759.37226.YahooMailNeo@web126005.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 12 March 2013 11:59:19 Facix Booka wrote:

>I would like to hand over my work to you kernel people. May be my problems 
>and fixes are only sience fiction to other problems in somewhere else what I 
>did not see. Default value can be use_mem_cache=1. 
>Print out "eth0: kevent 2 may have been dropped" may need attention.


Hi,

I am sorry, but this won't do.

1. It is too subtle
2. the resume() code path
3. use a pool if this is a real problem

	Regards
		Oliver
