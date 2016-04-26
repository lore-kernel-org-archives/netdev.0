From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH V2 1/5] samples/bpf: add back functionality to
 redefine LLC command
Date: Tue, 26 Apr 2016 10:28:12 -0700
Message-ID: <20160426172810.GB42777@ast-mbp.thefacebook.com>
References: <20160426162650.22962.20516.stgit@firesoul>
 <20160426162711.22962.13821.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kbuild@vger.kernel.org,
	bblanco@plumgrid.com, naveen.n.rao@linux.vnet.ibm.com,
	borkmann@iogearbox.net
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160426162711.22962.13821.stgit@firesoul>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 26, 2016 at 06:27:11PM +0200, Jesper Dangaard Brouer wrote:
> It is practical to be-able-to redefine the location of the LLVM
> command 'llc', because not all distros have a LLVM version with bpf
> target support.  Thus, it is sometimes required to compile LLVM from
> source, and sometimes it is not desired to overwrite the distros
> default LLVM version.
> 
> This feature was removed with 128d1514be35 ("samples/bpf: Use llc in
> PATH, rather than a hardcoded value").
> 
> Add this features back. Note that it is possible to redefine the LLC
> on the make command like:
> 
>  make samples/bpf/ LLC=~/git/llvm/build/bin/llc
> 
> Fixes: 128d1514be35 ("samples/bpf: Use llc in PATH, rather than a hardcoded value")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>

