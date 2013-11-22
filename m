From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [2/2] gro: Clean up tcpX_gro_receive checksum verification
Date: Thu, 21 Nov 2013 21:58:18 -0800
Message-ID: <1385099898.10637.75.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5286F018.8060801@gmail.com>
	 <20131116064611.GA12146@gondor.apana.org.au> <528A51B6.2040609@intel.com>
	 <20131121.133501.272071098922555423.davem@davemloft.net>
	 <20131122023013.GA6387@gondor.apana.org.au>
	 <20131122023210.GB6506@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alexander.h.duyck@intel.com,
	alexander.duyck@gmail.com, netdev@vger.kernel.org,
	edumazet@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:58551 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819Ab3KVF6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 00:58:20 -0500
Received: by mail-pa0-f51.google.com with SMTP id fa1so838164pad.24
        for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 21:58:19 -0800 (PST)
In-Reply-To: <20131122023210.GB6506@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-22 at 10:32 +0800, Herbert Xu wrote:
> This patch simplifies the checksum verification in tcpX_gro_receive
> by reusing the CHECKSUM_COMPLETE code for CHECKSUM_NONE.  All it
> does for CHECKSUM_NONE is compute the partial checksum and then
> treat it as if it came from the hardware (CHECKSUM_COMPLETE).
>     
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Eric Dumazet <edumazet@google.com>
