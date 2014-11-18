From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH net-next] PPC: bpf_jit_comp: Unify BPF_MOD | BPF_X and
 BPF_DIV | BPF_X
Date: Tue, 18 Nov 2014 12:50:44 +1100
Message-ID: <1416275444.1107.4.camel@concordia>
References: <1416254861-3879-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Philippe Bergheaud <felix@linux.vnet.ibm.com>,
	linuxppc-dev@ozlabs.org, Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:36417 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753156AbaKRBuq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2014 20:50:46 -0500
In-Reply-To: <1416254861-3879-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-17 at 23:07 +0300, Denis Kirjanov wrote:
> Reduce duplicated code by unifying
> BPF_ALU | BPF_MOD | BPF_X and BPF_ALU | BPF_DIV | BPF_X
> 
> CC: Alexei Starovoitov<alexei.starovoitov@gmail.com>
> CC: Daniel Borkmann<dborkman@redhat.com>
> CC: Philippe Bergheaud<felix@linux.vnet.ibm.com>
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>

Please include the output of the test suite.

Assuming that's OK I'm happy for it to go in.

cheers
