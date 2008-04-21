From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] make icmp_sk_init() static
Date: Mon, 21 Apr 2008 02:32:26 -0700 (PDT)
Message-ID: <20080421.023226.237529768.davem@davemloft.net>
References: <20080421084845.GR26897@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60883
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753738AbYDUJcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 05:32:24 -0400
In-Reply-To: <20080421084845.GR26897@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Mon, 21 Apr 2008 11:48:45 +0300

> This patch makes the needlessly global icmp_sk_init() static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Also applied, thanks Adrian.

BTW, I noticed that some of your patches get posted like
this:

> d163a44e24881d5e960bf9bdc1819ba8ccd15555 diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> index f064031..fee171e 100644

with the commit ID newline missing, so that the diff specification
shares the same line as the commit ID.

Oddly some of your patch postings do not have this missing newline.

Any idea what causes this?  Just curious :-)
