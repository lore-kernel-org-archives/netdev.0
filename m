From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPv6]: use container_of() macro in fib6_clean_node()
Date: Mon, 08 Oct 2007 20:40:03 -0700 (PDT)
Message-ID: <20071008.204003.04077004.davem@davemloft.net>
References: <20071008163316.16798.19433.stgit@frecb000701.frec.bull.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59729
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753178AbXJIDkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 23:40:04 -0400
In-Reply-To: <20071008163316.16798.19433.stgit@frecb000701.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Mon, 08 Oct 2007 18:33:16 +0200

> In ip6_fib.c, fib6_clean_node() casts a fib6_walker_t pointer to
> a fib6_cleaner_t pointer assuming a struct fib6_walker_t (field 'w')
> is the first field in struct fib6_walker_t.
> 
> To prevent any future problems that may occur if one day a field
> is inadvertently inserted before the 'w' field in struct fib6_cleaner_t,
> (and to improve readability), this patch uses the container_of() macro.
> 
> Patch for net-2.6.24
> 
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Applied, thanks Benjamin.
