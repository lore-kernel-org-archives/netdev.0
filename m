From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next-2.6 PATCH 0/6 v4] macvlan: MAC Address filtering
 support for passthru mode
Date: Thu, 2 Feb 2012 10:50:38 +0200
Message-ID: <20120202085037.GA26085@redhat.com>
References: <1321575301.2749.51.camel@bwh-desktop>
 <CAEE6B20.3A9F7%roprabhu@cisco.com>
 <20120202072448.GA25403@redhat.com>
 <4F2A4D81.6070002@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roprabhu@cisco.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, davem@davemloft.net, chrisw@redhat.com,
	sri@us.ibm.com, dragos.tatulea@gmail.com, kvm@vger.kernel.org,
	arnd@arndb.de, gregory.v.rose@intel.com, mchan@broadcom.com,
	dwang2@cisco.com, shemminger@vyatta.com, eric.dumazet@gmail.com,
	kaber@trash.net, benve@cisco.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56385 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753755Ab2BBIvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Feb 2012 03:51:08 -0500
Content-Disposition: inline
In-Reply-To: <4F2A4D81.6070002@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2012 at 12:46:57AM -0800, John Fastabend wrote:
> On 2/1/2012 11:24 PM, Michael S. Tsirkin wrote:
> > On Sun, Nov 20, 2011 at 08:30:24AM -0800, Roopa Prabhu wrote:
> >>
> >>
> >>
> >> On 11/17/11 4:15 PM, "Ben Hutchings" <bhutchings@solarflare.com> wrote:
> >>
> >>> Sorry to come to this rather late.
> >>>
> >>> On Tue, 2011-11-08 at 23:55 -0800, Roopa Prabhu wrote:
> >>> [...]
> >>>> v2 -> v3
> >>>> - Moved set and get filter ops from rtnl_link_ops to netdev_ops
> >>>> - Support for SRIOV VFs.
> >>>>         [Note: The get filters msg (in the way current get rtnetlink handles
> >>>>         it) might get too big for SRIOV vfs. This patch follows existing
> >>>> sriov 
> >>>>         vf get code and tries to accomodate filters for all VF's in a PF.
> >>>>         And for the SRIOV case I have only tested the fact that the VF
> >>>>         arguments are getting delivered to rtnetlink correctly. The code
> >>>>         follows existing sriov vf handling code so rest of it should work
> >>>> fine]
> >>> [...]
> >>>
> >>> This is already broken for large numbers of VFs, and increasing the
> >>> amount of information per VF is going to make the situation worse.  I am
> >>> no netlink expert but I think that the current approach of bundling all
> >>> information about an interface in a single message may not be
> >>> sustainable.
> >>
> >> Yes agreed. I have the same concern.
> > 
> > So it seems that we need to extend the existing interface to allow
> > tweaking filters per VF. Does it need to block this
> > patchset though? After all, we'll need to support the existing
> 
> hmm not sure I follow what patchset is this blocking?

The one you are replying to.
