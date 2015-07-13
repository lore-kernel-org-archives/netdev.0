From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] ebpf: remove self-assignment in interpreter's
 tail call
Date: Mon, 13 Jul 2015 11:53:59 -0700
Message-ID: <55A40947.2000706@plumgrid.com>
References: <6586042063b52e17a355fce15460ee16c1ee95bf.1436812762.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:32993 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbbGMSxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 14:53:48 -0400
Received: by pdbqm3 with SMTP id qm3so84645788pdb.0
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 11:53:47 -0700 (PDT)
In-Reply-To: <6586042063b52e17a355fce15460ee16c1ee95bf.1436812762.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/13/15 11:49 AM, Daniel Borkmann wrote:
> ARG1 = BPF_R1 as it stands, evaluates to regs[BPF_REG_1] = regs[BPF_REG_1]
> and thus has no effect. Add a comment instead, explaining what happens and
> why it's okay to just remove it. Since from user space side, a tail call is
> invoked as a pseudo helper function via bpf_tail_call_proto, the verifier
> checks the arguments just like with any other helper function and makes
> sure that the first argument (regs[BPF_REG_1])'s type is ARG_PTR_TO_CTX.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks!
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
