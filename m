From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net: diag: fix a potential security issue
Date: Sat, 21 Oct 2017 02:27:37 +0100 (WEST)
Message-ID: <20171021.022737.1906342496133825805.davem@davemloft.net>
References: <cover.1508398111.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
        marcelo.leitner@gmail.com, sd@queasysnail.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46306 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752963AbdJUB1l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 21:27:41 -0400
In-Reply-To: <cover.1508398111.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 19 Oct 2017 15:32:23 +0800

> This patch is to void the potential security issue that the family
> or protocol modules are autoloaded when requesting _diag module by
> not requesting _diag module if the family or protocol is not added
> or registered in sock_diag and inet_diag.
> 
> As the repost of the patch '[PATCH net] sock_diag: request _diag
> module only when the family or proto has been registered', this
> patchset fixes the compiling errors when INET is not set, and
> also split into two patches to make it clear to review.

This makes no sense to me.

Any user can just open a socket() in the appropriate protocol
family to cause the module to be loaded.

If someone wants modules to not be loaded, block them using
traditional module loading infrastructure mechanisms.  Or
don't load the module at all.

Sorry I am not applying this.
