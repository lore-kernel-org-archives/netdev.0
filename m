From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: ni52.c warnings explosion
Date: Thu, 21 Feb 2008 10:56:16 +0000
Message-ID: <20080221105616.52c2406f@core>
References: <1203578784.20345.4.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:56560 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759011AbYBULF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 06:05:27 -0500
In-Reply-To: <1203578784.20345.4.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Feb 2008 23:26:24 -0800
Harvey Harrison <harvey.harrison@gmail.com> wrote:

> Dave,
> 
> Somewhere between 2.6.25-rc1 and -rc2 something changed that produces a
> few hundred sparse warnings in ni52.c.

I gave it a massive clean up but I've not annotated it
> 
> I see Alan touched it last.
> 
> drivers/net/ni52.c:219:15: warning: incorrect type in argument 1 (different address spaces)
> drivers/net/ni52.c:219:15:    expected void const volatile [noderef] <asn:2>*addr
> drivers/net/ni52.c:219:15:    got unsigned char *<noident>
> 
> If you want the full log, let me know.

Throw it my way. I'll go through it but its probably mostly about
annotating it now it uses io spaces.
