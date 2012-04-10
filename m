From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH v1 7/7] macvlan: add FDB bridge ops and new
 macvlan mode
Date: Tue, 10 Apr 2012 18:30:14 +0300
Message-ID: <20120410153014.GA20488@redhat.com>
References: <20120409215419.3288.50790.stgit@jf-dev1-dcblab>
 <20120409220053.3288.40867.stgit@jf-dev1-dcblab>
 <20120410080916.GB26540@redhat.com>
 <4F843544.8060209@intel.com>
 <20120410134321.GB18899@redhat.com>
 <4F8442F6.5070707@intel.com>
 <20120410143500.GD19556@redhat.com>
 <4F84511D.7060902@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roprabhu@cisco.com, stephen.hemminger@vyatta.com,
	davem@davemloft.net, hadi@cyberus.ca, bhutchings@solarflare.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gregory.v.rose@intel.com, krkumar2@in.ibm.com, sri@us.ibm.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46285 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753460Ab2DJPae (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 11:30:34 -0400
Content-Disposition: inline
In-Reply-To: <4F84511D.7060902@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 10, 2012 at 08:26:21AM -0700, John Fastabend wrote:
> On 4/10/2012 7:35 AM, Michael S. Tsirkin wrote:
> > On Tue, Apr 10, 2012 at 07:25:58AM -0700, John Fastabend wrote:
> >>> Hmm okay, but this would mean we should convert
> >>> MACVLAN_MODE_PASSTHRU_NOPROMISC to something
> >>> that can combined with all modes. E.g.
> >>> MACVLAN_MODE_BRIDGE | MACVLAN_MODE_FLAG_XXXXX
> >>>
> >>> and document that it does not promise to flood
> >>> multicast.
> >>>
> >>
> >> How about changing MACVLAN_MODE_PASSTHRU_NOPROMISC -> MACVLAN_MODE_NOPORMISC
> >> for this patch. Then a follow on series can rework bridge
> >> and VEPA to use it as well.
> > 
> > Right. We probably need a better name if it's going to
> > affect other things besides promisc though.
> > 
> 
> how about MACVLAN_MODE_FDBFLAG?

The idea being that no one figures out what this means so
no one will make any wrong assumptions? ;)

-- 
MST
