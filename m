From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [patch 5/5] d80211: allow wireless vlan interface to havesameMAC an AP interface
Date: Tue, 10 Oct 2006 06:42:26 -0700
Message-ID: <20061010134226.GA4518@devicescape.com>
References: <20061003181118.537800000@devicescape.com> <20061003181233.GE19403@devicescape.com> <1160343128.4701.6.camel@johannes.berg> <20061009213807.GH26254@instant802.com> <1160477427.2727.8.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <jkm@devicescape.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:29639 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1750767AbWJJNmo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 09:42:44 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1160477427.2727.8.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 10, 2006 at 12:50:27PM +0200, Johannes Berg wrote:
> On Mon, 2006-10-09 at 14:38 -0700, Jouni Malinen wrote:
> 
> > Yes, I just merged in support for this (dynamic VLANs) into hostapd.
> > RADIUS Access-Accept is used select VLAN is being used and the STA is
> > bound at that point to another virtual interface, if needed.
> 
> Different question. How do broadcasts to a vlan interface work? Are they
> rewritten to unicasts to all vlan stations? 

no, still broadcasts, but in a typical deployment some for of encryption
is used.  Each vlan has a unique broadcast key so stations on one vlan
cannot decrypt packets from another vlan. 

-David
