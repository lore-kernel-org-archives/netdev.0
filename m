From: Stephen Hemminger <shemminger@osdl.org>
Subject: [BUG] can't unload network device's if IPV6 is loaded
Date: Thu, 11 Dec 2003 15:33:34 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031211153334.0c59214b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
        YOSHIFUJI
 Hideaki<yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In 2.6.0-test11, IPV6 is not correctly cleaning up the network device reference's
(ie missing dev_put).  So if I do:
	rmmod e100
it hangs forever and complains about that not all references have been cleaned up.

This happens even if no IPV6 addresses have been set up. Just having ipv6 available
to be loaded at boot up.  The vendor startup scripts (SuSe 9) may be setting something.

-- 
Stephen Hemminger 		mailto:shemminger@osdl.org
Open Source Development Lab	http://developer.osdl.org/shemminger
