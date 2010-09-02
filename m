From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] change sk->sk_forward_alloc to atomic
Date: Thu, 02 Sep 2010 13:53:57 -0700 (PDT)
Message-ID: <20100902.135357.35036599.davem@davemloft.net>
References: <20100902204706.29795.6982.stgit@maxim-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: franchoze@yandex.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33697
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757175Ab0IBUxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 16:53:41 -0400
In-Reply-To: <20100902204706.29795.6982.stgit@maxim-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Franchoze <franchoze@yandex.ru>
Date: Fri, 03 Sep 2010 00:47:06 +0400

> Patch fixes issue bellow.

sk_forward_alloc should not need to be changed into an atomic_t,
it should only be accessed when the socket is locked.
