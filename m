From: Michal Sekletar <msekleta@redhat.com>
Subject: Re: [PATCH] filter: introduce SKF_AD_VLAN_PROTO BPF extension
Date: Fri, 6 Mar 2015 09:09:51 +0100
Message-ID: <20150306080951.GB2841@morgoth.brq.redhat.com>
References: <1425501718-12066-1-git-send-email-msekleta@redhat.com>
 <54F77336.7040006@plumgrid.com>
 <20150305103715.GA3432@morgoth.brq.redhat.com>
 <54F889EB.7000203@plumgrid.com>
 <54F8B680.4050307@iogearbox.net>
 <54F8BF4A.3090702@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>, guy@alum.mit.edu,
	atzm@stratosphere.co.jp
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54275 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754365AbbCFIKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 03:10:16 -0500
Content-Disposition: inline
In-Reply-To: <54F8BF4A.3090702@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 05, 2015 at 12:40:42PM -0800, Alexei Starovoitov wrote:
> On 3/5/15 12:03 PM, Daniel Borkmann wrote:
> >On 03/05/2015 05:52 PM, Alexei Starovoitov wrote:
> >>imo there is a benefit of giving programs more visibility into
> >>skb metadata.
> >
> >I'm not really a big fan of it, but given we added commit a0cdfcf39362
> >("packet: deliver VLAN TPID to userspace") to packet sockets ...
> 
> good point, since skb->vlan_proto is already exposed to user space
> via that commit, it makes sense to let bpf see it as well.
> For consistency with tpacket, I'd call it SKF_AD_VLAN_TPID

Thanks everyone for taking the time to look into this. I will post v2 soon.
Hopefully addressing all the problems brought up.

Michal

> 
