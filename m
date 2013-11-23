From: David Miller <davem@davemloft.net>
Subject: Re: [2/2] gro: Clean up tcpX_gro_receive checksum verification
Date: Sat, 23 Nov 2013 14:47:21 -0800 (PST)
Message-ID: <20131123.144721.431033829456826541.davem@davemloft.net>
References: <20131122023013.GA6387@gondor.apana.org.au>
	<20131122023210.GB6506@gondor.apana.org.au>
	<1385099898.10637.75.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, alexander.h.duyck@intel.com,
	alexander.duyck@gmail.com, netdev@vger.kernel.org,
	edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756471Ab3KWWiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 17:38:51 -0500
In-Reply-To: <1385099898.10637.75.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 21 Nov 2013 21:58:18 -0800

> On Fri, 2013-11-22 at 10:32 +0800, Herbert Xu wrote:
>> This patch simplifies the checksum verification in tcpX_gro_receive
>> by reusing the CHECKSUM_COMPLETE code for CHECKSUM_NONE.  All it
>> does for CHECKSUM_NONE is compute the partial checksum and then
>> treat it as if it came from the hardware (CHECKSUM_COMPLETE).
>>     
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
