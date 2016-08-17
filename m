From: Tejun Heo <htejun@fb.com>
Subject: Re: [RFC PATCH 2/5] cgroup: add bpf_{e,in}gress pointers
Date: Wed, 17 Aug 2016 13:56:16 -0400
Message-ID: <20160817175615.GA10620@htj.duckdns.org>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <1471442448-1248-3-git-send-email-daniel@zonque.org>
 <20160817175038.GB98226@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Daniel Mack <daniel@zonque.org>, <daniel@iogearbox.net>,
	<ast@fb.com>, <davem@davemloft.net>, <kafai@fb.com>,
	<fw@strlen.de>, <pablo@netfilter.org>, <harald@redhat.com>,
	<netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:55690 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752435AbcHQR4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 13:56:46 -0400
Content-Disposition: inline
In-Reply-To: <20160817175038.GB98226@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Aug 17, 2016 at 10:50:40AM -0700, Alexei Starovoitov wrote:
> > +config CGROUP_BPF
> > +	bool "Enable eBPF programs in cgroups"
> > +	depends on BPF_SYSCALL
> > +	help
> > +	  This options allows cgroups to accommodate eBPF programs that
> > +	  can be used for network traffic filtering and accounting. See
> > +	  Documentation/networking/filter.txt for more information.
> > +
> 
> I think this extra config is unnecessary. It makes the code harder to follow.
> Anyone turning on bpf syscall and cgroups should be able to have this feature.
> Extra config is imo overkill.

Agreed, the added code is pretty small, especially in comparison to
both cgroup and bpf, and the only memory overhead would be four
pointers per cgroup, which shouldn't be noticeable at all.

Thanks.

-- 
tejun
