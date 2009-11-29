From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [ethtool PATCH] ethtool: Add Direct Attach to the available
 connector ports
Date: Sun, 29 Nov 2009 10:35:51 -0800
Message-ID: <1259519751.2211.22.camel@ppwaskie-mobl2>
References: <20091125101315.24481.11759.stgit@localhost.localdomain>
	 <20091129.003601.253425360.davem@davemloft.net>
	 <4B125014.9080507@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:65297 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751455AbZK2Sfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Nov 2009 13:35:46 -0500
In-Reply-To: <4B125014.9080507@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-11-29 at 03:42 -0700, Jeff Garzik wrote:
> On 11/29/2009 03:36 AM, David Miller wrote:
> > From: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> > Date: Wed, 25 Nov 2009 02:13:15 -0800
> >
> >> From: PJ Waskiewicz<peter.p.waskiewicz.jr@intel.com>
> >>
> >> This adds Direct Attach SFP+ types to the connector ports
> >> for the GSET mode.
> >>
> >> Signed-off-by: Peter P Waskiewicz Jr<peter.p.waskiewicz.jr@intel.com>
> >> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> >
> > Jeff Garzik, ping?
> 
> These days, unless I have some massive objection, I merge stuff into 
> ethtool when the kernel bits hit net-next.  ethtool should be current as 
> of net-next 24 hrs ago.
> 
> I queued the ethtool patch in $subject, and was waiting on your kernel 
> merge verdict.
> 
> 
> > Also, do you plan on doing any ethtool releases this century? :-)
> 
> I've been trying to think of what would be a good versioning scheme for 
> ethtool.  Even though it is [essentially] a user-friendly kernel 
> interface, its releases have never really been closely synchronized with 
> the kernel releases.  And unlike a lot of other software, ethtool is so 
> simple it does not really go through any release-candidate or beta period.
> 
> The current scheme just increments a release number: 5->6, 6->7, etc. 
> But with so few kernel releases (and thus ethtool releases), I was 
> leaning towards either yearly release naming ("ethtool-2009"), kernel 
> release naming ("ethtool-2.6.33"), or the release scheme proposed for 
> glibc:  snapshot directly from the git repository.
> 
> If people want one, I could do a release right now.  Or, we could move 
> to an alternate scheme like git snapshots.  I think git snapshots are 
> viable because ethtool has historically had next to zero bugs in the 
> actual userland utility.  Fedora already imports git snapshots, for example.
> 

I think we need a better versioning scheme no matter what method is
chosen.  If there are git snapshots, then part of the version in the
repo should include the git repo stamp, or a timestamp.  For example,
Fedora packages with the timestamp of the snapshot, but the actual
version of ethtool is "6git."  That isn't very helpful to me, since the
git snapshots with version 6git could be different.

That's my $0.02.

Cheers,
-PJ

