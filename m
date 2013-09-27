From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH v2.40 3/7] ofp-actions: Add OFPUTIL_OFPAT13_PUSH_MPLS
Date: Fri, 27 Sep 2013 12:30:10 -0700
Message-ID: <20130927193010.GB17506@nicira.com>
References: <1380241116-7661-1-git-send-email-horms@verge.net.au>
 <1380241116-7661-4-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog136.obsmtp.com ([74.125.149.85]:50396 "HELO
	na3sys009aog136.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753756Ab3I0TaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 15:30:16 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro12so2950865pbb.13
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 12:30:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1380241116-7661-4-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 27, 2013 at 09:18:32AM +0900, Simon Horman wrote:
> From: Joe Stringer <joe@wand.net.nz>
> 
> This patch adds a new compatibility enum for use with MPLS, so that the
> differing behaviour between OpenFlow 1.2 and 1.3 can be implemented in
> ofproto-dpif-xlate.

It seems a little awkward to me to do this via a new OFPACT_, mostly
because there isn't currently any distinction between OF1.1 and OF1.3 in
terms of OFPACT_ definitions.  Did you consider adding a new field to
struct ofpact_push_mpls that would say whether the label should be added
before or after a VLAN tag?
