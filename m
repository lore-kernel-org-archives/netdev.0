From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH V2 4/5] samples/bpf: allow make to be run from
 samples/bpf/ directory
Date: Tue, 26 Apr 2016 10:31:51 -0700
Message-ID: <20160426173149.GE42777@ast-mbp.thefacebook.com>
References: <20160426162650.22962.20516.stgit@firesoul>
 <20160426162727.22962.51631.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kbuild@vger.kernel.org,
	bblanco@plumgrid.com, naveen.n.rao@linux.vnet.ibm.com,
	borkmann@iogearbox.net
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35933 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772AbcDZRbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 13:31:55 -0400
Content-Disposition: inline
In-Reply-To: <20160426162727.22962.51631.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2016 at 06:27:27PM +0200, Jesper Dangaard Brouer wrote:
> It is not intuitive that 'make' must be run from the top level
> directory with argument "samples/bpf/" to compile these eBPF samples.
> 
> Introduce a kbuild make file trick that allow make to be run from the
> "samples/bpf/" directory itself.  It basically change to the top level
> directory and call "make samples/bpf/" with the "/" slash after the
> directory name.
> 
> Also add a clean target that only cleans this directory, by taking
> advantage of the kbuild external module setting M=$PWD.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
