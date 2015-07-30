From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 3/4] bpf, x86/sparc: show actual number of passes
 in bpf_jit_dump
Date: Thu, 30 Jul 2015 10:15:41 -0700
Message-ID: <55BA5BBD.2090806@plumgrid.com>
References: <cover.1438250937.git.daniel@iogearbox.net>
 <16c61aff6d8c8261a9edabc00a038b06780b0ee6.1438250937.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: holzheu@linux.vnet.ibm.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:36775 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754541AbbG3RPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 13:15:42 -0400
Received: by pdjr16 with SMTP id r16so28163858pdj.3
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 10:15:42 -0700 (PDT)
In-Reply-To: <16c61aff6d8c8261a9edabc00a038b06780b0ee6.1438250937.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/30/15 3:42 AM, Daniel Borkmann wrote:
> When bpf_jit_compile() got split into two functions via commit
> f3c2af7ba17a ("net: filter: x86: split bpf_jit_compile()"), bpf_jit_dump()
> was changed to always show 0 as number of compiler passes. Change it to
> dump the actual number. Also on sparc, we count passes starting from 0,
> so add 1 for the debug dump as well.
>
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
