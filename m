From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next] fix unsafe set_memory_rw from softirq
Date: Mon, 07 Oct 2013 15:17:23 -0400 (EDT)
Message-ID: <20131007.151723.1874328502711969492.davem@davemloft.net>
References: <1380870846-3357-1-git-send-email-ast@plumgrid.com>
	<1381078592.12191.0.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, dborkman@redhat.com, edumazet@google.com,
	heiko.carstens@de.ibm.com, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35242 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755566Ab3JGTR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 15:17:26 -0400
In-Reply-To: <1381078592.12191.0.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 06 Oct 2013 09:56:32 -0700

> On Fri, 2013-10-04 at 00:14 -0700, Alexei Starovoitov wrote:
>> on x86 system with net.core.bpf_jit_enable = 1
> 
>> cannot reuse jited filter memory, since it's readonly,
>> so use original bpf insns memory to hold work_struct
>> 
>> defer kfree of sk_filter until jit completed freeing
>> 
>> tested on x86_64 and i386
>> 
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

I've decided to apply this to 'net', thanks.
