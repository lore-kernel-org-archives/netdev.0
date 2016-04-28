From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V4 1/5] samples/bpf: add back functionality to
 redefine LLC command
Date: Thu, 28 Apr 2016 16:40:46 +0200
Message-ID: <20160428164046.0998f03d@redhat.com>
References: <20160428121949.16807.84828.stgit@firesoul>
	<20160428122053.16807.93143.stgit@firesoul>
	<20160428132132.GB7880@naverao1-tp.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kbuild@vger.kernel.org,
	bblanco@plumgrid.com, borkmann@iogearbox.net,
	alexei.starovoitov@gmail.com, brouer@redhat.com
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20160428132132.GB7880@naverao1-tp.in.ibm.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 Apr 2016 18:51:33 +0530
"Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com> wrote:

> > Add this features back. Note that it is possible to redefine the LLC
> > on the make command like:
> > 
> >  make samples/bpf/ LLC=~/git/llvm/build/bin/llc  
> 
> I don't have an objection to this patch, but you didn't explain why/how 
> this approach is better than just doing:
>   PATH=~/git/llvm/build/bin make samples/bpf/

It is almost the same. There is always another way to do the same.

I explicitly use this to test different combinations of LLC and CLANG,
in-order to validate Alexei's claim that older versions of CLANG could
still work with a newer version of LLC.  Thus, one use-case you
approach cannot cover ;-)

And clang seems to install a clang-3.9, which my solution also covers
by explicitly specifying CLANG=clang-3.9, if several avail clang's are
in the PATH.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
