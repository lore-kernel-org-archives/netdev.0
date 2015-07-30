From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 2/4] bpf: provide helper that indicates eBPF was
 migrated
Date: Thu, 30 Jul 2015 10:15:08 -0700
Message-ID: <55BA5B9C.6010406@plumgrid.com>
References: <cover.1438250937.git.daniel@iogearbox.net>
 <11e0f83fcc330f6f7bd0d427dc4c81b2a699b498.1438250937.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: holzheu@linux.vnet.ibm.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36487 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275AbbG3RPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 13:15:09 -0400
Received: by pdjr16 with SMTP id r16so28157184pdj.3
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 10:15:09 -0700 (PDT)
In-Reply-To: <11e0f83fcc330f6f7bd0d427dc4c81b2a699b498.1438250937.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/30/15 3:42 AM, Daniel Borkmann wrote:
> During recent discussions we had with Michael, we found that it would
> be useful to have an indicator that tells the JIT that an eBPF program
> had been migrated from classic instructions into eBPF instructions, as
> only in that case A and X need to be cleared in the prologue. Such eBPF
> programs do not set a particular type, but all have BPF_PROG_TYPE_UNSPEC.
> Thus, introduce a small helper for cde66c2d88da ("s390/bpf: Only clear
> A and X for converted BPF programs") and possibly others in future.
>
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>
> Cc: Michael Holzheu<holzheu@linux.vnet.ibm.com>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
