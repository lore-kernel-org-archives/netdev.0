From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH] filter: introduce SKF_AD_VLAN_PROTO BPF extension
Date: Fri, 6 Mar 2015 15:02:34 +0100
Message-ID: <20150306140233.GD25656@unicorn.suse.cz>
References: <1425501718-12066-1-git-send-email-msekleta@redhat.com>
 <54F77336.7040006@plumgrid.com>
 <20150305103715.GA3432@morgoth.brq.redhat.com>
 <54F889EB.7000203@plumgrid.com>
 <54F8B680.4050307@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Michal Sekletar <msekleta@redhat.com>, netdev@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>, guy@alum.mit.edu,
	atzm@stratosphere.co.jp
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:57359 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750843AbbCFOCh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 09:02:37 -0500
Content-Disposition: inline
In-Reply-To: <54F8B680.4050307@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 05, 2015 at 09:03:12PM +0100, Daniel Borkmann wrote:
> On 03/05/2015 05:52 PM, Alexei Starovoitov wrote:
> 
> >At this point I think it's up to Dave to decide whether we need
> >this patch (after fixing the issue pointed by Denis) or not.
> >imo there is a benefit of giving programs more visibility into
> >skb metadata.
> 
> I'm not really a big fan of it, but given we added commit a0cdfcf39362
> ("packet: deliver VLAN TPID to userspace") to packet sockets ...

IMHO the motivation here was not to allow filtering by TPID but because
without it, libpcap and its users had no chance to get this information
for packets captured on devices with Rx VLAN offloading so that e.g.
"tcpdump -e" was showing (guessed) TPID of 0x8100 for all of them, no
matter what the actual TPID was.

                                                         Michal Kubecek
