From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: fix possible seqlock deadlock in
 ip6_finish_output2
Date: Sat, 30 Nov 2013 08:45:55 -0800
Message-ID: <1385829955.5352.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <13025162.118881385612276530.JavaMail.weblogic@epv6ml01>
	 <1385659390.5352.20.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1385661082.5352.34.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131128192231.GE24171@order.stressinduktion.org>
	 <20131129053944.GH24171@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jongman.heo@samsung.com, David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:54839 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327Ab3K3Qp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 11:45:58 -0500
In-Reply-To: <20131129053944.GH24171@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-29 at 06:39 +0100, Hannes Frederic Sowa wrote:
> IPv6 stats are 64 bits and thus are protected with a seqlock. By not
> disabling bottom-half we could deadlock here if we don't disable bh and
> a softirq reentrantly updates the same mib.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

(Note that the seqlock is only for 32bit arches)
