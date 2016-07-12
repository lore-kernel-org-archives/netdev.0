From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] ipv4: af_inet: make it explicitly non-modular
Date: Mon, 11 Jul 2016 22:44:46 -0700 (PDT)
Message-ID: <20160711.224446.2106737333882776551.davem@davemloft.net>
References: <20160711203751.13516-1-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37032 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbcGLFor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 01:44:47 -0400
In-Reply-To: <20160711203751.13516-1-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 11 Jul 2016 16:37:51 -0400

> The Makefile controlling compilation of this file is obj-y,
> meaning that it currently is never being built as a module.
> 
> Since MODULE_ALIAS is a no-op for non-modular code, we can simply
> remove the MODULE_ALIAS_NETPROTO variant used here.
> 
> We replace module.h with kmod.h since the file does make use of
> request_module() in order to load other modules from here.
> 
> We don't have to worry about init.h coming in via the removed
> module.h since the file explicitly includes init.h already.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied to net-next, thanks.
