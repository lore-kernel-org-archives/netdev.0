From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Bonding][patch] Adding Transmit load balancing mode to bonding
Date: Thu, 27 Mar 2003 08:06:27 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030327.080627.71980411.davem@redhat.com>
References: <Pine.LNX.4.44.0303271705580.7106-100000@jrslxjul4.npdj.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net,
   bonding-announce@lists.sourceforge.net, linux-net@vger.kernel.org,
   netdev@oss.sgi.com, linux-kernel@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: <Pine.LNX.4.44.0303271705580.7106-100000@jrslxjul4.npdj.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: shmulik.hen@intel.com
   Date: Thu, 27 Mar 2003 17:38:02 +0200 (IST)

   Balancing is connection oriented (e.g. by IPv4 destination address)
   so packet order is always kept.

You could also key off of the destination/source port as well for
UDP/TCP/SCTP.  Have you experimented with this?
