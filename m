From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: make xfrm_algo.c a module
Date: Mon, 14 May 2012 18:37:21 -0400 (EDT)
Message-ID: <20120514.183721.1989442389245940694.davem@davemloft.net>
References: <4FAA3EAF02000078000826E4@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: JBeulich@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932305Ab2ENWh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 18:37:26 -0400
In-Reply-To: <4FAA3EAF02000078000826E4@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jan Beulich" <JBeulich@suse.com>
Date: Wed, 09 May 2012 08:53:51 +0100

> By making this a standalone config option (selected as needed),
> selecting CRYPTO from here rather than from XFRM (which is boolean)
> allows the core crypto code to become a module again even when XFRM=y.
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>
 ...
> @@ -15,9 +15,6 @@
>  #include <linux/crypto.h>
>  #include <linux/scatterlist.h>
>  #include <net/xfrm.h>
> -#if defined(CONFIG_INET_AH) || defined(CONFIG_INET_AH_MODULE) || defined(CONFIG_INET6_AH) || defined(CONFIG_INET6_AH_MODULE)
> -#include <net/ah.h>
> -#endif

This is completely unrelated to the change you are trying to make in
this patch.

It belongs in a separate change.
