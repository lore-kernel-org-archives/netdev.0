From: "Zou, Yi" <yi.zou@intel.com>
Subject: RE: Question regarding protocol specific mtu for FCoE
Date: Wed, 3 Jun 2009 15:25:39 -0700
Message-ID: <7C88852EF6F99F4EB538472FCFEBE2223A7E70ED@orsmsx509.amr.corp.intel.com>
References: <7C88852EF6F99F4EB538472FCFEBE2223A7E6F45@orsmsx509.amr.corp.intel.com>
	<4A26BAF7.3070301@hp.com>
	<7C88852EF6F99F4EB538472FCFEBE2223A7E6FBD@orsmsx509.amr.corp.intel.com>
	<4A26E4AE.4020607@hp.com> <adazlcp814o.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	"Dev, Vasu" <vasu.dev@intel.com>,
	"Love, Robert W" <robert.w.love@intel.com>,
	"Ma, Steve" <steve.ma@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Roland Dreier <rdreier@cisco.com>, Rick Jones <rick.jones2@hp.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <adazlcp814o.fsf@cisco.com>
Content-Language: en-US
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > So FCoE cannot say "fcoe_mtu = min(OPTIMAL_FCOEMTU,netdev->mtu)" and
> > send-down frames based on that?
>
>I think the point is that FCoE wants to use OPTIMAL_FCOEMTU (2KB + a
>bit
>for headers) even when netdev->mtu is 1500.  (eg datacenter network
>supports baby jumbo frames so FCoE traffic that stays within the
>network
>should use OPTIMAL_FCOEMTU, while lots of IP traffic is going out onto
>a
>1500-byte MTU campus and having TCP doing lots of PMTU discovery is a
>pain)
>
> - R.

Yes, exactly, thanks for the clarification. Also, since FC max payload
of 2112 is not going to change, I guess the OPTIMAL_FCOEMTU is probably
going to stay unchanged forever.

Thanks.

yi
