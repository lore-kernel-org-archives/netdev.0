From: Thomas Graf <tgraf@suug.ch>
Subject: Re: netlink: Remove max_size setting
Date: Fri, 1 May 2015 06:23:32 +0200
Message-ID: <20150501042332.GA26676@pox.localdomain>
References: <20150501002759.GA31660@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:33917 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbbEAEXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 00:23:36 -0400
Received: by wgso17 with SMTP id o17so82003057wgs.1
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 21:23:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150501002759.GA31660@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/01/15 at 08:27am, Herbert Xu wrote:
> We currently limit the hash table size to 64K which is very bad
> as even 10 years ago it was relatively easy to generate millions
> of sockets.
> 
> Since the hash table is naturally limited by memory allocation
> failure, we don't really need an explicit limit so this patch
> removes it.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Thomas Graf <tgraf@noironetworks.com>
