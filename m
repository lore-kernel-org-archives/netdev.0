From: "Zou, Yi" <yi.zou@intel.com>
Subject: Question regarding protocol specific mtu for FCoE
Date: Wed, 3 Jun 2009 10:56:41 -0700
Message-ID: <7C88852EF6F99F4EB538472FCFEBE2223A7E6F45@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	"Dev, Vasu" <vasu.dev@intel.com>,
	"Love, Robert W" <robert.w.love@intel.com>,
	"Ma, Steve" <steve.ma@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
I am trying to figure out a way to support a different MTU for Fiber
Channel over Ethernet (FCoE), where it is preferred to have a baby jumbo
frame with MTU=2158 (14 bytes FCoE header + 24 bytes FC header + 2112
bytes max FC payload + 4 bytes FC CRC + 4 bytes FCoE trailer).

Similar to nedev->mtu being used everywhere for LAN traffic, I wonder if
it is desirable or feasible to add another protocol specific MTU (which
is my case is FCoE) to netdev so any eth driver supporting converged
traffic (e.g. LAN + FCoE) over netdev can make use of it.

Thanks.

Yi Zou

