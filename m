From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/4] samples/bpf: Simplify building BPF samples
Date: Fri, 1 Apr 2016 00:21:39 +0530
Message-ID: <20160331185139.GD17907@naverao1-tp.ibm.com>
References: <922f95fb5d16686367a66d2d4bd176149a87e9ad.1459423412.git.naveen.n.rao@linux.vnet.ibm.com>
 <0ce1c8bdff478db55490a90db6732c4db9de6f22.1459423412.git.naveen.n.rao@linux.vnet.ibm.com>
 <56FD632B.4040306@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	"David S . Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp02.au.ibm.com ([202.81.31.144]:33717 "EHLO
	e23smtp02.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778AbcCaSxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 14:53:06 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <naveen.n.rao@linux.vnet.ibm.com>;
	Fri, 1 Apr 2016 04:53:03 +1000
Content-Disposition: inline
In-Reply-To: <56FD632B.4040306@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/03/31 10:49AM, Alexei Starovoitov wrote:
> On 3/31/16 4:25 AM, Naveen N. Rao wrote:
> >Make BPF samples build depend on CONFIG_SAMPLE_BPF. We still don't add a
> >Kconfig option since that will add a dependency on llvm for allyesconfig
> >builds which may not be desirable.
> >
> >Those who need to build the BPF samples can now just do:
> >
> >make CONFIG_SAMPLE_BPF=y
> >
> >or:
> >
> >export CONFIG_SAMPLE_BPF=y
> >make
> 
> I don't like this 'simplification'.
> make samples/bpf/
> is much easier to type than capital letters.

This started out as a patch to have the BPF samples built with a Kconfig 
option. As stated in the commit description, I realised that it won't 
work for allyesconfig builds. However, the reason I retained this patch 
is since it gets us one step closer to building the samples as part of 
the kernel build.

The 'simplification' is since I can now have the export in my .bashrc 
and the kernel build will now build the BPF samples too without 
requiring an additional 'make samples/bpf/' step.

I agree this is subjective, so I am ok if this isn't taken in.


- Naveen
