From: Stephen Hemminger <shemminger@osdl.org>
Subject: 2.6.12-rc5-tcp3
Date: Wed, 25 May 2005 11:32:31 -0700
Message-ID: <20050525113231.4b5fef39@dxpl.pdx.osdl.net>
References: <20050524163939.0fb86509@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050524163939.0fb86509@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

http://developer.osdl.org/shemminger/patches/2.6.12-rc5-tcp3

Keep up with the new 2.6.12-rc5
More minor tweaks:
	- tcp_ack26 is already in rc5
	+ change to min_cwnd to be same (ie ssthresh/2) for all reno like protocols
	  eventually plan to fix the cwnd undershoot bug 
		http://thread.gmane.org/gmane.linux.network/2094 
		http://oss.sgi.com/projects/netdev/archive/2005-04/msg00338.html
