From: David Vrabel <david.vrabel@citrix.com>
Subject: xen-netback regression in 3.10.18
Date: Thu, 7 Nov 2013 12:15:33 +0000
Message-ID: <527B8465.6050901@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "stable@vger.kernel.org" <stable@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Durrant <paul.durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3.10.18 included 279f438e36c0 (xen-netback: Don't destroy the netdev
until the vif is shut down) but this has a regression that was fixed by
dc62ccaccfb1 (xen-netback: transition to CLOSED when removing a VIF)

dc62ccaccfb1 depends on ea732dff5cfa (xen-netback: Handle backend state
transitions in a more robust way) which is also a bug fix for certain
Windows frontend drivers and is thus also a stable candidate.

Dave can you ensure these two commits are tagged for the next 3.10.y
stable release?

  ea732dff5cfa10789007bf4a5b935388a0bb2a8f
  dc62ccaccfb139d9b04bbc5a2688a4402adbfab3

Thanks.

David
