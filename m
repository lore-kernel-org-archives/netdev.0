From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCHv3 perf/core 0/7] Reuse libbpf from samples/bpf
Date: Thu, 15 Dec 2016 12:35:11 -0300
Message-ID: <20161215153511.GD6866@kernel.org>
References: <20161209024620.31660-1-joe@ovn.org>
 <20161209150907.GM8257@kernel.org>
 <584ACE2E.2090108@iogearbox.net>
 <20161214132501.GP5482@kernel.org>
 <20161214145512.GQ5482@kernel.org>
 <CAPWQB7E-i+m0Ukz6O39AV-pHMB=GsoUTTa1862QUjGWM3RQJyQ@mail.gmail.com>
 <20161215143329.GB6866@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Wang Nan <wangnan0@huawei.com>,
        ast@fb.com
To: Joe Stringer <joe@ovn.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161215143329.GB6866@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Thu, Dec 15, 2016 at 11:33:29AM -0300, Arnaldo Carvalho de Melo escreveu:
> Em Wed, Dec 14, 2016 at 02:46:23PM -0800, Joe Stringer escreveu:
> > On 14 December 2016 at 06:55, Arnaldo Carvalho de Melo <acme@kernel.org> wrote:
> > > So, Joe, can you try refreshing this work, starting from what I have in
> > > perf/core? It has the changes coming from net-next that Daniel warned us about
> > > and some more.
>  
> > I've just respun this series based on the version you previously
> > applied to perf/core. Since bpf_prog_{attach,detach}() were added to
> > samples/libbpf, a new patch will shift these over to tools/lib/bpf.
> > Other than that, I folded "samples/bpf: Drop unnecessary build
> > targets." back into "samples/bpf: Switch over to libbpf", and I
> > noticed that there were a couple of unnecessary log buffers with the
> > latest changes. For any new sample programs, those were fixed up to
> > use libbpf as well.
>  
> > Don't forget to do a "make headers_install" before attempting to build
> > the samples, access to the latest headers is required (as per the
> > readme in samples/bpf).
> 
> Ah, README, I should read that ;-)
> 
> I got used to how tools/perf/ work, i.e. it is self sufficient wrt
> in-flux stuff in the kernel, i.e.  headers that are related to features
> it supports and that are under constant improvements, such as eBPF, kvm,
> syscall tables, etc.
> 
> Anyway, will do the headers_install step inside a container, to avoid
> polluting my workstation.

heh: should've read that file, now I did:

<quote>
There are usually dependencies to header files of the current kernel.
To avoid installing devel kernel headers system wide, as a normal
user, simply call::

 make headers_install

This will creates a local "usr/include" directory in the git/build top
level directory, that the make system automatically pickup first.
</quote>
 
> Thanks for doing the respin and for the clarifications about building
> samples/bpf/.
> 
> - Arnaldo
