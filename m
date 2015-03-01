From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/10] eBPF support for cls_bpf
Date: Sun, 01 Mar 2015 00:28:39 -0500 (EST)
Message-ID: <20150301.002839.859474631671429798.davem@davemloft.net>
References: <cover.1425040939.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36974 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbbCAF2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 00:28:41 -0500
In-Reply-To: <cover.1425040939.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 27 Feb 2015 15:55:32 +0100

> This is the non-RFC version of my patchset posted before netdev01 [1]
> conference. It contains a couple of eBPF cleanups and preparation
> patches to get eBPF support into cls_bpf. The last patch adds the
> actual support. I'll post the iproute2 parts after the kernel bits
> are merged, an initial preview link to the code is mentioned in the
> last patch.
> 
> Patch 4 and 5 were originally one patch, but I've split them into
> two parts upon request as patch 4 only is also needed for Alexei's
> tracing patches that go via tip tree.
> 
> Tested with tc and all in-kernel available test suites.
> 
> I have configured and built LLVM with --enable-experimental-targets=BPF
> but as Alexei put it, the plan is to get rid of the experimental
> status in future [2].

Daniel please respin this without the arch patches, those should
go via the various arch maintainer's tree(s).
