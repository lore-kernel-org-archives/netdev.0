From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] drivers/net/macvtap: fix error check
Date: Mon, 7 Mar 2011 10:59:04 +0100
Message-ID: <201103071059.04321.arnd@arndb.de>
References: <20110305004941.7b195e9d@absol.kitzblitz>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicolas Kaiser <nikai@nikai.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:55552 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755007Ab1CGJ7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 04:59:13 -0500
In-Reply-To: <20110305004941.7b195e9d@absol.kitzblitz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 05 March 2011, Nicolas Kaiser wrote:
> 'len' is unsigned of type size_t and can't be negative.
> 
> Signed-off-by: Nicolas Kaiser <nikai@nikai.net>

Acked-by: Arnd Bergmann <arnd@arndb.de>

I think it's harmless: the worst thing that can happen is
macvtap_alloc_skb() failing with ENOMEM when it gets a
large argument, but we could have it in -stable just to
be sure.

	Arnd
