From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.40 3/7] ofp-actions: Add OFPUTIL_OFPAT13_PUSH_MPLS
Date: Mon, 30 Sep 2013 10:13:44 +0900
Message-ID: <20130930011344.GB4768@verge.net.au>
References: <1380241116-7661-1-git-send-email-horms@verge.net.au>
 <1380241116-7661-4-git-send-email-horms@verge.net.au>
 <20130927193010.GB17506@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:52851 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753426Ab3I3BNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Sep 2013 21:13:52 -0400
Content-Disposition: inline
In-Reply-To: <20130927193010.GB17506@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 27, 2013 at 12:30:10PM -0700, Ben Pfaff wrote:
> On Fri, Sep 27, 2013 at 09:18:32AM +0900, Simon Horman wrote:
> > From: Joe Stringer <joe@wand.net.nz>
> > 
> > This patch adds a new compatibility enum for use with MPLS, so that the
> > differing behaviour between OpenFlow 1.2 and 1.3 can be implemented in
> > ofproto-dpif-xlate.
> 
> It seems a little awkward to me to do this via a new OFPACT_, mostly
> because there isn't currently any distinction between OF1.1 and OF1.3 in
> terms of OFPACT_ definitions.  Did you consider adding a new field to
> struct ofpact_push_mpls that would say whether the label should be added
> before or after a VLAN tag?

Hi Ben,

I think that the main reason that Joe and I (probably much more I than Joe)
chose to use OFPACT_ the way that we did is that it seemed to be in keeping
with the way the code already works. Clearly you don't feel that is the
case which seems entirely reasonable to me. I'll see about re-working the
code as you have suggested.
