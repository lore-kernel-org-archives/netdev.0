From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: Multicast packet loss
Date: Mon, 09 Mar 2009 18:56:35 -0400
Message-ID: <49B59EA3.3000208@athenacr.com>
References: <20090204012144.GC3650@localhost.localdomain>	<49A6CE39.5050200@athenacr.com>	<49A8FAFF.7060104@cosmosbay.com> <20090304.001646.100690134.davem@davemloft.net> <49AE3DA9.2020103@cosmosbay.com> <49B2266C.9050701@cosmosbay.com> <49B3F655.6030308@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kchang@athenacr.com, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:1025 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751599AbZCIXTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 19:19:42 -0400
In-Reply-To: <49B3F655.6030308@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Here is a patch that helps. It's still an RFC of course, since its somewhat ugly :)

Hi Eric,

I did some experimenting with this patch today -- we're users, not kernel hackers,
but the performance looks great. We see no loss with mcasttest, and no loss with
our internal test programs (which do much more user-space work). We're very
encouraged :)

One thing I'm curious about: previously, setting /proc/irq/<eth0>/smp_affinity
to one CPU made things perform better, but with this patch, performance is better
with smp_affinity == ff than with smp_affinity == 1. Do you know why that
is? Our tests are all with bnx2 msi_disable=1. I can investigate with oprofile
tomorrow.

Thank you for your continued help, we all deeply appreciate having someone
looking at this workload.

Thanks,
Brian Bloniarz
