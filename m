From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][ATM] use rtnl_{lock,unlock} during device operations
 (take 2)
Date: Tue, 17 Jun 2003 10:53:33 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617.105333.13769070.davem@redhat.com>
References: <20030606.085558.56056656.davem@redhat.com>
	<200306171754.h5HHsWsG000656@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas@cmf.nrl.navy.mil
In-Reply-To: <200306171754.h5HHsWsG000656@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: chas williams <chas@cmf.nrl.navy.mil>
   Date: Tue, 17 Jun 2003 13:52:32 -0400

   In message <20030606.085558.56056656.davem@redhat.com>,"David S. Miller" writes
   :
   >Tell me it at least uses netlink ;(
   
   so i was doing a bit of thinking about this netlink conversion for
   signalling (and lane and clip and br2684).  would i create a new
   family for each like NETLINK_SIGNALLING, NETLINK_LANE, or create a
   single new family NETLINK_ATM and multiplex nlmsg_type, or use the
   existing NETLINK_USERSOCK?

Don't user NETLINK_USERSOCK, it's for users :-)

Create NETLINK_ATM, and then multiplex like rtnetlink does
on the message type.

   
