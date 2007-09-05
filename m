From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC] iw_cxgb3: Support "iwarp-only" interfaces to avoid 4-tuple conflicts with the host stack.
Date: Wed, 05 Sep 2007 08:18:00 -0700
Message-ID: <ada642puonr.fsf@cisco.com>
References: <1187905185.5547.13.camel@stevo-desktop>
	<adaveawwcpz.fsf@cisco.com> <46DD762F.80904@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: general@lists.openfabrics.org, ewg@lists.openfabrics.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sean.hefty@intel.com
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:30827 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756692AbXIEPSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 11:18:05 -0400
In-Reply-To: <46DD762F.80904@opengridcomputing.com> (Steve Wise's message of "Tue, 04 Sep 2007 10:13:51 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > What's wrong with my suggestion of having the iwarp driver create an
 > > "iwX" interface to go with the normal "ethX" interface?  It seems
 > > simpler to me, and there's a somewhat similar precedent with how
 > > mac80211 devices create both wlan0 and wmaster0 interfaces.
 > >  - R.
 > 
 > It seemed much more painful for me to implement. :-)
 > 
 > I'll look into this, but I think for this to be done, the changes must
 > be in the cxgb3 driver, not the rdma driver, because the guts of the
 > netdev struct are all private to cxgb3.  Remember that this interface
 > needs to still do non TCP traffic (like ARP and UDP)...
 > 
 > Maybe you have something in mind here that I'm not thinking about?

No, I was just spouting off.

But the whole "create a magic alias" seems kind of unfriendly to the
user.  Maybe as you said, the cxgb3 net driver could create the alias
for the iw_cxgb3 driver?

 - R.
