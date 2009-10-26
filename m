From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] make per interface sysctl entries configurable
Date: Sun, 25 Oct 2009 21:31:02 -0700
Message-ID: <20091025213102.7368fe70@nehalam>
References: <200910251954.49700.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Cosmin Ratiu <cratiu@ixiacom.com>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42592 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752095AbZJZEbE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2009 00:31:04 -0400
In-Reply-To: <200910251954.49700.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 25 Oct 2009 19:54:49 +0200
Octavian Purdila <opurdila@ixiacom.com> wrote:

> 
> RFC patches are attached.
> 
> Another possible approach: add an interface flag and use it to decide whether 
> we want per interface sysctl entries or not.
> 
> Benchmarks for creating 1000 interface (with the ndst module previously posted 
> on the list, ppc750 @800Mhz machine):
> 
> - without the patches:
> 
> real    4m 38.27s
> user    0m 0.00s
> sys     2m 18.90s
> 
> - with the patches:
> 
> real    0m 0.10s
> user    0m 0.00s
> sys     0m 0.05s
> 
> Thanks,
> tavi

I would rather optimize the algorithm than give up and make it
not available. It should be possible to do better by just using some
better programming.

-- 
