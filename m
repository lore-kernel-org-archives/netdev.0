From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 3/3] bnx2i: Add bnx2i iSCSI driver.
Date: Tue, 27 May 2008 17:48:49 -0700
Message-ID: <1211935729.18326.185.camel@dell>
References: <ada8wy07osq.fsf@cisco.com>
 <1211578969.26900.5.camel@dhcp-10-13-110-217.broadcom.com>
 <adave0z24o4.fsf@cisco.com>
 <20080527.125247.73979652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, anilgv@broadcom.com, michaelc@cs.wisc.edu,
	netdev <netdev@vger.kernel.org>, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20080527.125247.73979652.davem@davemloft.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2008-05-27 at 12:52 -0700, David Miller wrote:
> From: Roland Dreier <rdreier@cisco.com>
> Date: Tue, 27 May 2008 07:38:19 -0700
> 
> > So you are creating sockets just to reserve TCP ports to avoid host
> > stack clashes with your offload engine?  Wasn't this approach strongly
> > rejected (in the context of iWARP) in the past?
> 
> Yes, it was, and likewise similar hacks in other areas will
> be rejected similarly.
> 

If we change the implementation to use a separate IP address and
separate MAC address for iSCSI, will it be acceptable?  The iSCSI IP/MAC
addresses will be unknown to the Linux TCP stack and so no sharing of
the 4-tuple space will be needed.

The patches will be very similar, except that all inet calls and
notifiers will be removed.



