From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.62] datapath: Add basic MPLS support to kernel
Date: Sun, 29 Jun 2014 09:02:15 +0900
Message-ID: <20140629000215.GC9487@verge.net.au>
References: <1403611017-10965-1-git-send-email-horms@verge.net.au>
 <CAEP_g=9yYqKy-=aiTi3=3cZNOombBgkjHdzLdRzYVVKyJCHqcQ@mail.gmail.com>
 <20140625015149.GB14193@verge.net.au>
 <20140628005531.GA4122@verge.net.au>
 <CAEP_g=8vbFvHRrKwCKBGxJZBhxnZDoE8f+eDOq3Z1JNo_U_H9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Joe Stringer <joe@wand.net.nz>, Thomas Graf <tgraf@suug.ch>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:36474 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751968AbaF2ACT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2014 20:02:19 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=8vbFvHRrKwCKBGxJZBhxnZDoE8f+eDOq3Z1JNo_U_H9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 28, 2014 at 08:59:01AM -0700, Jesse Gross wrote:
> On Fri, Jun 27, 2014 at 5:55 PM, Simon Horman <horms@verge.net.au> wrote:
> > On Wed, Jun 25, 2014 at 10:51:52AM +0900, Simon Horman wrote:
> >> On Tue, Jun 24, 2014 at 04:24:37PM -0700, Jesse Gross wrote:
> >> >  * Maybe you can refresh my memory - in the case of a push_mpls after
> >> > pop_vlan, why can't we do this check correctly for at least one level
> >> > of vlan? It seems like we could use the inner EtherType to tell
> >> > whether an additional vlan tag is present.
> >>
> >> That seems likely. I'll do some analysis and get back to you.
> >
> > I may be missing something but it seems to me that in
> > ovs_nla_copy_actions__() we have access to the outer EtherType and
> > VLAN TCI but not the inner EtherType.
> >
> > It seems to me that the inner EtherType would need to be present
> > in the key for it to be available in ovs_nla_copy_actions__().
> 
> The inner EtherType (first level) is actually what is stored in
> eth.type in the flow. When eth.tci is set it is assumed that the outer
> EtherType is 0x8100 and that isn't stored.

Yes, of course. Sorry for missing that.
