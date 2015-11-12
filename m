From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net 1/1] r8169: fix kasan reported skb use-after-free.
Date: Thu, 12 Nov 2015 13:51:41 -0500 (EST)
Message-ID: <20151112.135141.1605194071638702692.davem@redhat.com>
References: <20151111223518.GA29672@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@codemonkey.org.uk,
	edumazet@google.com, vinschen@redhat.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34094 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754399AbbKLSvt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2015 13:51:49 -0500
In-Reply-To: <20151111223518.GA29672@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 11 Nov 2015 23:35:18 +0100

> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Reported-by: Dave Jones <davej@codemonkey.org.uk>
> Fixes: d7d2d89d4b0af ("r8169: Add software counter for multicast packages")
> Acked-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Corinna Vinschen <vinschen@redhat.com>
> ---
> 
>  Applies to davem's net as of c5a37883f42be712a989e54d5d6c0159b0e56599
>  ("Merge branch 'akpm' (patches from Andrew)")
> 
>  4.2 needs it as well.

Applied and queued up for -stable, thanks!
