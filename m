From: Takashi Hibi <hibi665@oki.com>
Subject: Source Specific Query of MLDv2
Date: Thu, 15 Jan 2004 22:18:41 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115221841.7e7cc78d%hibi665@oki.com>
Mime-Version: 1.0
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

I found another problem of MLDv2.
The host doesn't respond to Source Specific Query.
It happens in the following scenario.

At first, host join multicast address with source address.
Then MLDv2 router issues Source Specific Query.
The source address of the query packet is link-local address of the 
router's interface, and the destination address is the multicast address 
to be queried. (See section 5.1.4 in draft-vida-mld-v2-08.txt) 

But it seems that the query packet is filtered by ipv6_chk_mcast_addr(), 
since the source address is not included in the source list.
As a result, no response to the query is produced .

Regards,
Takashi Hibi

 
