From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: CONFIG_XPS depends on L1_CACHE_BYTES being greater than
 sizeof(struct xps_map)
Date: Fri, 23 Oct 2015 14:38:37 -0700
Message-ID: <1445636317.22974.188.camel@edumazet-glaptop2.roam.corp.google.com>
References: <32A3BF6F-B243-4AD4-9AE9-A5F9DAE0270A@bell.net>
	 <B8E85737-5ECD-4CBE-8730-886B098C5FA4@bell.net>
	 <trinity-eda7d55d-7234-4b29-a15c-955f8ba0c95e-1445513884942@3capp-gmx-bs32>
	 <trinity-8980ad10-b889-45cf-8f37-a33ba9cf99ef-1445514797080@3capp-gmx-bs32>
	 <1445524549.2207.1.camel@HansenPartnership.com> <5628F868.3040105@bell.net>
	 <5629404B.8090805@gmx.de>
	 <1445550615.22974.128.camel@edumazet-glaptop2.roam.corp.google.com>
	 <562A8990.9000808@gmx.de>
	 <1445630588.22974.187.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151023210810.GA1969@ls3530.box>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-parisc@vger.kernel.org,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	John David Anglin <dave.anglin@bell.net>,
	Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Helge Deller <deller@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33877 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbbJWVij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 17:38:39 -0400
In-Reply-To: <20151023210810.GA1969@ls3530.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-23 at 23:08 +0200, Helge Deller wrote:

> Can you then maybe give me an Acked-by or signed-off for the patch below?
> It further adds a compile-time check to avoid that XPS_MIN_MAP_ALLOC
> gets calculated to zero on any architecture - otherwise no queues would
> be allocated. 
> 
> In addition I would like to push it for v4.3 then through my parisc-tree
> (after keeping it in for-next for 1-2 days), together with the patch
> which reduces L1_CACHE_BYTES to 16 on parisc.
> Would that be OK too? 

Sure !

Acked-by: Eric Dumazet <edumazet@google.com>
