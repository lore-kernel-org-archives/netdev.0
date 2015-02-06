From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6 v2 net-next] rhashtable fixes
Date: Fri, 06 Feb 2015 15:20:06 -0800 (PST)
Message-ID: <20150206.152006.822025850109308588.davem@davemloft.net>
References: <cover.1423097592.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	ying.xue@windriver.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58240 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711AbbBFXUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 18:20:09 -0500
In-Reply-To: <cover.1423097592.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu,  5 Feb 2015 02:03:30 +0100

> This series fixes all remaining known issues with rhashtable that
> have been reported. In particular the race condition reported by
> Ying Xue.
> 
> ---
> Dave/Herbert: I'm posting this now as it fixes real issues. I'm
> fine with taking Herbert's rehash patches instead if they resolve
> all the reported issues as well.
> 
> v2:
>  - Rebased on top of Herbert Xu's iterator code
>  - Fixed last remaining race that remained. Special thanks
>    to Daniel Borkmann for assistance while debugging.

Since this supposedly fixes crashes on bootup for some people
I'm applying this series now.

Herbert, I apologize in advance if this makes your work more
difficult but I asked you yesterday what you wanted me to
do with this series...

Thanks.
