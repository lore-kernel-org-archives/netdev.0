From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [net-next PATCH V3 1/5] samples/bpf: add back functionality to
 redefine LLC command
Date: Wed, 27 Apr 2016 13:36:33 +0530
Message-ID: <20160427080609.GB14936@naverao1-tp.in.ibm.com>
References: <20160427072855.29959.70252.stgit@firesoul>
 <20160427073013.29959.86846.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kbuild@vger.kernel.org,
	bblanco@plumgrid.com, borkmann@iogearbox.net,
	alexei.starovoitov@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160427073013.29959.86846.stgit@firesoul>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/04/27 09:30AM, Jesper Dangaard Brouer wrote:
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

Why not do:
  PATH=~/git/llvm/build/bin:$PATH make samples/bpf/

..if you wish to override clang/llc only for building bpf samples?
Or, just export the updated $PATH:
  export PATH=~/git/llvm/build/bin:$PATH
  make samples/bpf


- Naveen
 

