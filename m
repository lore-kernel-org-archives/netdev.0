From: Tejun Heo <htejun@fb.com>
Subject: Re: [RFC PATCH 3/5] bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH
 commands
Date: Wed, 17 Aug 2016 11:08:50 -0400
Message-ID: <20160817150849.GC6299@htj.duckdns.org>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <1471442448-1248-4-git-send-email-daniel@zonque.org>
 <20160817142047.GB4021@htj.duckdns.org>
 <95e8b773-416f-72cc-4045-dd10d94e6484@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <daniel@iogearbox.net>, <ast@fb.com>, <davem@davemloft.net>,
	<kafai@fb.com>, <fw@strlen.de>, <pablo@netfilter.org>,
	<harald@redhat.com>, <netdev@vger.kernel.org>
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56042 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752106AbcHQPJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 11:09:17 -0400
Content-Disposition: inline
In-Reply-To: <95e8b773-416f-72cc-4045-dd10d94e6484@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, again.

Just one addition.

On Wed, Aug 17, 2016 at 04:35:24PM +0200, Daniel Mack wrote:
> created. To bring this more in line with how cgroups usually work, I
> guess we should add code to copy over the bpf programs from the ancestor
> once a new cgroup is instantiated.

Please don't copy the actual configuration or program.  Every case
where a cgroup controller took this approach turned out pretty badly.
It gets really confusing.

Thanks.

-- 
tejun
