From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/1] netfilter/jump_label: use HAVE_JUMP_LABEL?
Date: Thu, 21 Aug 2014 17:24:35 +0200
Message-ID: <20140821152435.GB16498@breakpoint.cc>
References: <1408589568-27046-1-git-send-email-yizhouzhou@ict.ac.cn>
 <20140821121132.GA16498@breakpoint.cc>
 <1498523.4b875.147f8a0e3c8.Coremail.yizhouzhou@ict.ac.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Zhouyi Zhou <zhouzhouyi@gmail.com>, pablo@netfilter.org,
	kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbaron@akamai.com
To: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1498523.4b875.147f8a0e3c8.Coremail.yizhouzhou@ict.ac.cn>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zhouyi Zhou <yizhouzhou@ict.ac.cn> wrote:
> > > 
> > > CONFIG_JUMP_LABEL doesn't ensure HAVE_JUMP_LABEL, if it
> > > is not the case use maintainers's own mutex to guard
> > > the modification of global values.
> 
> CONFIG_JUMP_LABEL says the user wants to use jump labels.
> But we also need the toolchain to support it.
> 
> That is reflected in CC_HAVE_ASM_GOTO=y, and if both are
> set then HAVE_JUMP_LABEL is set to true.

Please resubmit and update the changelog to reflect this,
e.g. add something like

Use HAVE_JUMP_LABEL as elsewhere in the kernel to ensure
that the toolchain has the required support in addition to
CONFIG_JUMP_LABEL being set.
