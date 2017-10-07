From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v7 0/5] bpf: add two helpers to read perf
 event enabled/running time
Date: Sat, 07 Oct 2017 23:06:15 +0100 (WEST)
Message-ID: <20171007.230615.453122717434468471.davem@davemloft.net>
References: <20171005161923.332790-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, rostedt@goodmis.org, ast@fb.com,
        daniel@iogearbox.net, netdev@vger.kernel.org, kernel-team@fb.com
To: yhs@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42812 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752710AbdJGWJD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 18:09:03 -0400
In-Reply-To: <20171005161923.332790-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yonghong Song <yhs@fb.com>
Date: Thu, 5 Oct 2017 09:19:18 -0700

> Hardware pmu counters are limited resources. When there are more
> pmu based perf events opened than available counters, kernel will
> multiplex these events so each event gets certain percentage
> (but not 100%) of the pmu time. In case that multiplexing happens,
> the number of samples or counter value will not reflect the
> case compared to no multiplexing. This makes comparison between
> different runs difficult.
> 
> Typically, the number of samples or counter value should be
> normalized before comparing to other experiments. The typical
> normalization is done like:
>   normalized_num_samples = num_samples * time_enabled / time_running
>   normalized_counter_value = counter_value * time_enabled / time_running
> where time_enabled is the time enabled for event and time_running is
> the time running for event since last normalization.
> 
> This patch set implements two helper functions.
> The helper bpf_perf_event_read_value reads counter/time_enabled/time_running
> for perf event array map. The helper bpf_perf_prog_read_value read
> counter/time_enabled/time_running for bpf prog with type BPF_PROG_TYPE_PERF_EVENT.

Series applied to net-next, thanks.
