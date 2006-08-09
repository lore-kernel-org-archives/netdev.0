From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [PATCH 2/2] [IPV4] route: Dynamic hash table sizing.
Date: Wed, 09 Aug 2006 14:12:43 +0400
Message-ID: <44D9B51B.5060004@tls.msk.ru>
References: <20060809.004920.59469729.davem@davemloft.net> <20060809.005337.104642177.davem@davemloft.net> <200608091209.29231.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:37728 "EHLO hobbit.corpit.ru")
	by vger.kernel.org with ESMTP id S1030634AbWHIKMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 06:12:49 -0400
In-Reply-To: <200608091209.29231.dada1@cosmosbay.com>
To: unlisted-recipients:; (no To-header on input)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 09 August 2006 09:53, David Miller wrote:
[]
> -       mult = ((u64)ip_rt_gc_interval) << long_log2(hmask + 1);
> +       mult = ((u64)(hmask + 1)) << (u64)ip_rt_gc_interval;

Hmm.. shift *by* a 64-bit number?

/mjt
