From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Bonding][patch] Adding Transmit load balancing mode to bondi
 ng
Date: Tue, 01 Apr 2003 08:58:17 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030401.085817.56963537.davem@redhat.com>
References: <E791C176A6139242A988ABA8B3D9B38A014C92C4@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net,
   bonding-announce@lists.sourceforge.net, linux-net@vger.kernel.org,
   netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A014C92C4@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Hen, Shmulik" <shmulik.hen@intel.com>
   Date: Tue, 1 Apr 2003 19:09:09 +0300 

   We haven't experimented with layer 4 load balancing in the past. I guess
   this is because of the big overhead of parsing the skb for the necessary
   data, but also because of the risk of dealing with IP fragmentation, large
   send issues, encryption and all kinds of off-loadings.
   
In the modern internet, a fragmented TCP packet is nearly a bug.  And
if it's encrypted, you will never see the TCP headers to begin with.
Finally, there are no "large send" issues, the TCP port information
will always be in the front of the packet.

I brought this up because it is very clear to me that various
load-balancing daemons distributed by other gigabit card vendors are
keying on the connection information in TCP packets.  So someone
thinks it is worthwhile :-)
