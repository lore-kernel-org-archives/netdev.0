From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 0/3] netfilter: Use pr_<level> and pr_fmt
Date: Thu, 11 Jun 2009 13:04:58 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0906111303260.1795@fbirervta.pbzchgretzou.qr>
References: <cover.1244705154.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:52276 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760269AbZFKLE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 07:04:59 -0400
In-Reply-To: <cover.1244705154.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2009-06-11 09:40, Joe Perches wrote:

>Many of the calls to netfilter printk calls do not
>have KERN_<level> prefixes.
>
>Convert printks with KERN_<level> to pr_<level>
>and use pr_info for unprefixed printks.
>
>Remove the function names in printk strings and add
>#define pr_fmt(fmt) "%s:%s " fmt, KBUILD_MODNAME, __func__

Hm I had wished there was a better way than to replicate
this define over all Netfilter files.
Perhaps stuff it into an include.

