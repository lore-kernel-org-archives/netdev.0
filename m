From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 1/4] test_bpf: assign type to native eBPF test
 cases
Date: Thu, 30 Jul 2015 10:14:13 -0700
Message-ID: <55BA5B65.4040902@plumgrid.com>
References: <cover.1438250937.git.daniel@iogearbox.net>
 <45cfb718190f86817a7662e58499a08f30521404.1438250937.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: holzheu@linux.vnet.ibm.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:33221 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325AbbG3ROP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 13:14:15 -0400
Received: by pdbnt7 with SMTP id nt7so27615074pdb.0
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 10:14:15 -0700 (PDT)
In-Reply-To: <45cfb718190f86817a7662e58499a08f30521404.1438250937.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/30/15 3:42 AM, Daniel Borkmann wrote:
> As JITs start to perform optimizations whether to clear A and X on eBPF
> programs in the prologue, we should actually assign a program type to the
> native eBPF test cases. It doesn't really matter which program type, as
> these instructions don't go through the verifier, but it needs to be a
> type != BPF_PROG_TYPE_UNSPEC. This reflects eBPF programs loaded via bpf(2)
> system call (!= type unspec) vs. classic BPF to eBPF migrations (== type
> unspec).
>
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>
> Cc: Michael Holzheu<holzheu@linux.vnet.ibm.com>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
