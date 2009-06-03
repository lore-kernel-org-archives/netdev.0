From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Question regarding protocol specific mtu for FCoE
Date: Wed, 03 Jun 2009 16:27:25 -0700
Message-ID: <adaiqjc99uq.fsf@cisco.com>
References: <7C88852EF6F99F4EB538472FCFEBE2223A7E6F45@orsmsx509.amr.corp.intel.com>
	<4A26BAF7.3070301@hp.com>
	<7C88852EF6F99F4EB538472FCFEBE2223A7E6FBD@orsmsx509.amr.corp.intel.com>
	<4A26E4AE.4020607@hp.com> <adazlcp814o.fsf@cisco.com>
	<4A26FB01.1020502@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Zou\, Yi" <yi.zou@intel.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi\@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"Leech\, Christopher" <christopher.leech@intel.com>,
	"Dev\, Vasu" <vasu.dev@intel.com>,
	"Love\, Robert W" <robert.w.love@intel.com>,
	"Ma\, Steve" <steve.ma@intel.com>,
	"Waskiewicz Jr\, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Kirsher\, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <4A26FB01.1020502@hp.com> (Rick Jones's message of "Wed, 03 Jun
	2009 15:36:49 -0700")
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 > Aren't all stations in the same broadcast domain "supposed" to have
 > the same MTU, at least down at L2? So, a station in the broadcast
 > domain just doing IP and a station in the broadcast domain doing
 > IP+FCoE "should" have the same MTU at the HW level right?
 > 
 > I could see where there would be lots of PMTU going-on if the
 > communications were to off-campus sites also had an FCoE upping their
 > MTU.  Otherwise, the MSS exchange at connection establishment is going
 > to preclude it right?  PMTU only "hits" when one has a so called
 > "dumb-bell" network which is "wider" at the ends than in the middle.

Yes, I think such dumb-bell networks would be pretty common (servers in
two different data centers with FCoE enabled, talking through an
old-school WAN with 1500 MTU).  And even if they're not as common I
think, we probably do want to have some way to handle this.

I'm probably not as up on old and/or obscure networking protocols, but
to me FCoE is the first time I've been forced to think about coexistence
of IP and non-IP protocols through the same netdev.

 - R.
