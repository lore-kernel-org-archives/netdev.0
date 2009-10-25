From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [RFC] make per interface sysctl entries configurable
Date: Sun, 25 Oct 2009 20:07:55 +0200
Message-ID: <200910252007.56089.denys@visp.net.lb>
References: <200910251954.49700.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cosmin Ratiu <cratiu@ixiacom.com>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:34359 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753800AbZJYSIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 14:08:07 -0400
In-Reply-To: <200910251954.49700.opurdila@ixiacom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Very interesting patch, because i have PPPoE and sysctl locking issue my issue 
N1(accorting to perf and oprofile) on massive pppoe login and during 
operation.
Probably i will try to apply it on one of loaded (but redundant, in case it 
will crash) pppoe.

On Sunday 25 October 2009 19:54:49 Octavian Purdila wrote:
> RFC patches are attached.
>
> Another possible approach: add an interface flag and use it to decide
> whether we want per interface sysctl entries or not.
>
> Benchmarks for creating 1000 interface (with the ndst module previously
> posted on the list, ppc750 @800Mhz machine):
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


