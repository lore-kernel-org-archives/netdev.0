From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] PPC: bpf_jit_comp: add SKF_AD_HATYPE
 instruction
Date: Fri, 07 Nov 2014 14:50:26 -0500 (EST)
Message-ID: <20141107.145026.945264099310112541.davem@davemloft.net>
References: <1415253755-4001-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	alexei.starovoitov@gmail.com, dborkman@redhat.com,
	felix@linux.vnet.ibm.com
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41601 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753134AbaKGTub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 14:50:31 -0500
In-Reply-To: <1415253755-4001-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Thu,  6 Nov 2014 09:02:35 +0300

> Add BPF extension SKF_AD_HATYPE to ppc JIT to check
> the hw type of the interface
> 
> JIT off:
> [   69.106783] test_bpf: #20 LD_HATYPE 48 48 PASS
> JIT on:
> [   64.721757] test_bpf: #20 LD_HATYPE 7 6 PASS
> 
> CC: Alexei Starovoitov<alexei.starovoitov@gmail.com>
> CC: Daniel Borkmann<dborkman@redhat.com>
> CC: Philippe Bergheaud<felix@linux.vnet.ibm.com>
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>

Can I get some reviews please?

Thanks.
