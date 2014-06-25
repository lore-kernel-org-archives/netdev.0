From: Markos Chandras <Markos.Chandras@imgtec.com>
Subject: Re: [PATCH 00/17] Misc MIPS/BPF fixes for 3.16
Date: Wed, 25 Jun 2014 09:12:10 +0100
Message-ID: <53AA845A.1070505@imgtec.com>
References: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com> <20140623.124919.2215480222213445820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-mips@linux-mips.org>, <dborkman@redhat.com>,
	<ast@plumgrid.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:42354 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755033AbaFYIMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 04:12:14 -0400
In-Reply-To: <20140623.124919.2215480222213445820.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/23/2014 08:49 PM, David Miller wrote:
> From: Markos Chandras <markos.chandras@imgtec.com>
> Date: Mon, 23 Jun 2014 10:38:43 +0100
> 
>> Here are some fixes for MIPS/BPF for 3.16. These fixes make
>> the bpf testsuite *almost* happy with only 2 tests (LD_IND_LL,
>> LD_IND_NET) failing at the moment. Since fixing the remaining tests
>> is not so trivial, it would be nice to have these fixes in 3.16 for now.
>>
>> The patches are based on the upstream-sfr/mips-for-linux-next tree
>> because they depend on https://patchwork.linux-mips.org/patch/7099/
> 
> You did not CC: netdev on patches 1, 2, and 3.  Please do not do this,
> people on this list will want to review the series as a whole.
> 
Apologies David. Patches 1,2,3 have nothing to do with bpf-jit and they
only fix/add MIPS micro-assembler instructions so I didn't though
netdev@ actually cared about that. I will be more careful in the future.

-- 
markos
