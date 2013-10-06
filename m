From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next] fix unsafe set_memory_rw from softirq
Date: Sun, 06 Oct 2013 09:56:32 -0700
Message-ID: <1381078592.12191.0.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380870846-3357-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:43955 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203Ab3JFQ4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Oct 2013 12:56:35 -0400
In-Reply-To: <1380870846-3357-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-04 at 00:14 -0700, Alexei Starovoitov wrote:
> on x86 system with net.core.bpf_jit_enable = 1

> cannot reuse jited filter memory, since it's readonly,
> so use original bpf insns memory to hold work_struct
> 
> defer kfree of sk_filter until jit completed freeing
> 
> tested on x86_64 and i386
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Acked-by: Eric Dumazet <edumazet@google.com>
