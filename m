From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: xfrm: xfrm_policy: fix inline not at
 beginning of declaration
Date: Tue, 07 Jan 2014 18:34:12 -0500 (EST)
Message-ID: <20140107.183412.1584306758322996233.davem@davemloft.net>
References: <1389133227-11086-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45921 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754374AbaAGXeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 18:34:15 -0500
In-Reply-To: <1389133227-11086-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue,  7 Jan 2014 23:20:27 +0100

> Fix three warnings related to:
> 
>   net/xfrm/xfrm_policy.c:1644:1: warning: 'inline' is not at beginning of declaration [-Wold-style-declaration]
>   net/xfrm/xfrm_policy.c:1656:1: warning: 'inline' is not at beginning of declaration [-Wold-style-declaration]
>   net/xfrm/xfrm_policy.c:1668:1: warning: 'inline' is not at beginning of declaration [-Wold-style-declaration]
> 
> Just removing the inline keyword is sufficient as the compiler will
> decide on its own about inlining or not.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
