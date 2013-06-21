From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.33] datapath: Add basic MPLS support to kernel
Date: Fri, 21 Jun 2013 09:39:56 +0900
Message-ID: <20130621003954.GA18705@verge.net.au>
References: <1371539209-31134-1-git-send-email-horms@verge.net.au>
 <20130620005653.GA21614@verge.net.au>
 <CAEP_g=8X-vdMQ7RngJyidKsxhaS_p6Pa8JVh3U+fD64rt2Umzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Joe Stringer <joe@wand.net.nz>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:45623 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758081Ab3FUAiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 20:38:54 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=8X-vdMQ7RngJyidKsxhaS_p6Pa8JVh3U+fD64rt2Umzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 20, 2013 at 12:28:32PM -0700, Jesse Gross wrote:
> On Wed, Jun 19, 2013 at 5:56 PM, Simon Horman <horms@verge.net.au> wrote:
> > On Tue, Jun 18, 2013 at 04:06:49PM +0900, Simon Horman wrote:
> >> Allow datapath to recognize and extract MPLS labels into flow keys
> >> and execute actions which push, pop, and set labels on packets.
> >>
> >> Based heavily on work by Leo Alterman, Ravi K, Isaku Yamahata and Joe Stringer.
> >>
> >> Cc: Ravi K <rkerur@gmail.com>
> >> Cc: Leo Alterman <lalterman@nicira.com>
> >> Cc: Isaku Yamahata <yamahata@valinux.co.jp>
> >> Cc: Joe Stringer <joe@wand.net.nz>
> >> Signed-off-by: Simon Horman <horms@verge.net.au>
> >>
> >> ---
> >>
> >> This patch depends on "gre: Restructure tunneling" which it aims
> >> to be compatible with.
> >
> > To clarify. The dependency relates to a conflict when applying this patch
> > which modifies datapath/linux/compat/gso.[ch], files that are
> > created by "gre: Restructure tunneling". I believe it would
> > be trivial to reverse the dependency so that this patch creates
> > those files and "gre: Restructure tunneling" applies on top of it
> > as the two patches add different functions to those files.
> >
> > As such I think it would be better to describe this patch
> > as compatible with "gre: Restructure tunneling" rather than
> > dependent on it.
> 
> I agree that's the case. However, now that the OVS GRE code is
> upstream, I think I can take just a quick pass over the GRE patch to
> get it in and then we won't have any dependency issues.

Thanks. Of course I am would be more than happy with that.
