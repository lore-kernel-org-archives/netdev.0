From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] PPC: bpf_jit_comp: add SKF_AD_HATYPE
 instruction
Date: Tue, 11 Nov 2014 13:40:02 -0500 (EST)
Message-ID: <20141111.134002.8147781185003778.davem@davemloft.net>
References: <1415599183-3883-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	alexei.starovoitov@gmail.com, dborkman@redhat.com,
	felix@linux.vnet.ibm.com
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbaKKSkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 13:40:05 -0500
In-Reply-To: <1415599183-3883-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Mon, 10 Nov 2014 08:59:43 +0300

> Add BPF extension SKF_AD_HATYPE to ppc JIT to check
> the hw type of the interface
> 
> Before:
> [   57.723666] test_bpf: #20 LD_HATYPE
> [   57.723675] BPF filter opcode 0020 (@0) unsupported
> [   57.724168] 48 48 PASS
> 
> After:
> [  103.053184] test_bpf: #20 LD_HATYPE 7 6 PASS
> 
> CC: Alexei Starovoitov<alexei.starovoitov@gmail.com>
> CC: Daniel Borkmann<dborkman@redhat.com>
> CC: Philippe Bergheaud<felix@linux.vnet.ibm.com>
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
> 
> v2: address Alexei's comments

Applied, thanks.
