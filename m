From: cranium 2003 <cranium.2003@gmail.com>
Subject: How much ARP requests need to single IP address?
Date: Thu, 3 Feb 2005 18:51:30 +0530
Message-ID: <1d55641b050203052150cbbea3@mail.gmail.com>
Reply-To: cranium 2003 <cranium.2003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.linux.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
In Linux kernel by adding debug statement i observe that if i ping to
host 10.0.0.5 with 10 packets then first i know network stack require
to resolve hosts IP to its Hardware ID by sending ARP on Ethernet LAN.
But then what i get that if i again ping for another 10 packets to
10.0.0.5 then ARP routine is called.
Why? Why linux kernel is not caching it. Infact its caching i check it
in debug statements then why network stack require to resolve 10.0.0.5
host to send packets to it?

Also i want to know once eth_header_cache called then all successive
packet to that cache host goes directly from hh->hh_output(skb) to
hard_start_xmit?
regards,
cranium
