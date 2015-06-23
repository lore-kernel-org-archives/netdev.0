From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bpf: BPF based latency tracing
Date: Tue, 23 Jun 2015 06:10:31 -0700 (PDT)
Message-ID: <20150623.061031.2284937918219178217.davem@davemloft.net>
References: <1434722444-10200-1-git-send-email-daniel.wagner@bmw-carit.de>
	<5584B9A5.9030602@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel.wagner@bmw-carit.de, daniel@iogearbox.net, mingo@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753565AbbFWM6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 08:58:46 -0400
In-Reply-To: <5584B9A5.9030602@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Fri, 19 Jun 2015 17:53:57 -0700

> On 6/19/15 7:00 AM, Daniel Wagner wrote:
>> BPF offers another way to generate latency histograms. We attach
>> kprobes at trace_preempt_off and trace_preempt_on and calculate the
>> time it takes to from seeing the off/on transition.
> ...
>> Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
> ...
>> With the rebase on net-next no additinal patches are needed and this
>> thing here runs fine.
> ...
>> samples/bpf/Makefile       |   4 ++
>>   samples/bpf/lathist_kern.c | 99
>>   +++++++++++++++++++++++++++++++++++++++++++
>>   samples/bpf/lathist_user.c | 103
>>   +++++++++++++++++++++++++++++++++++++++++++++
>>   3 files changed, 206 insertions(+)
>>   create mode 100644 samples/bpf/lathist_kern.c
>>   create mode 100644 samples/bpf/lathist_user.c
> 
> Thanks. That's a useful example.
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks.
