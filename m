From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] crypto: algif - fix warn: unsigned 'used' is
 never less than zero
Date: Wed, 25 Mar 2015 11:45:54 -0400 (EDT)
Message-ID: <20150325.114554.625753070227410964.davem@davemloft.net>
References: <20150325142919.4229.90027.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	herbert@gondor.apana.org.au
To: tadeusz.struk@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47216 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932203AbbCYPpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 11:45:55 -0400
In-Reply-To: <20150325142919.4229.90027.stgit@tstruk-mobl1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tadeusz Struk <tadeusz.struk@intel.com>
Date: Wed, 25 Mar 2015 07:29:19 -0700

> Change type from unsigned long to int to fix an issue reported by kbuild robot:
> crypto/algif_skcipher.c:596 skcipher_recvmsg_async() warn: unsigned 'used' is
> never less than zero.
> 
> Signed-off-by: Tadeusz Struk <tadeusz.struk@intel.com>

Applied.
