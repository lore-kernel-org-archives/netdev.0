From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V2 3/5] samples/bpf: add a README file to get
 users started
Date: Wed, 27 Apr 2016 08:30:25 +0200
Message-ID: <20160427083025.66187b6b@redhat.com>
References: <20160426162650.22962.20516.stgit@firesoul>
	<20160426162721.22962.25054.stgit@firesoul>
	<20160426173105.GD42777@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org,
	linux-kbuild@vger.kernel.org, bblanco@plumgrid.com,
	naveen.n.rao@linux.vnet.ibm.com, borkmann@iogearbox.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54915 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752505AbcD0Gab (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2016 02:30:31 -0400
In-Reply-To: <20160426173105.GD42777@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Apr 2016 10:31:06 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Tue, Apr 26, 2016 at 06:27:22PM +0200, Jesper Dangaard Brouer wrote:
> > +
> > +Manually compiling LLVM with 'bpf' support
> > +------------------------------------------
> > +
> > +In some LLVM versions the BPF target were marked experimental. They
> > +needed the 'cmake .. -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=BPF'.  Since
> > +version 3.7.1, LLVM adds a proper LLVM backend target for the BPF
> > +bytecode architecture.  
> 
> it's actually non-experimental since 3.7.0.
> It was experimental after 3.6 was released during development of 3.7.
> I doubt you can find this anywhere, so I suggest to just drop this paragraph.

Okay lets drop this paragraph, given the LLVM period was so short, it
does not make sense to mention here.

I will send a V3 patch series, as DaveM usually likes a full resubmit
(I'll add your acks to the other patches, but you need to ack this one).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
