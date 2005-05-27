From: "Atul Sabharwal" <iamatul@comcast.net>
Subject: Re: Re: [PATCH] (6/6) bridge: receive path optimization
Date: Thu, 26 May 2005 22:57:05 -0700
Message-ID: <009201c56280$e9b7cd00$0202a8c0@ATULSPC>
References: <20050526110425.27590eb8@dxpl.pdx.osdl.net><20050526.144638.71091166.davem@davemloft.net><20050526154857.3cb34d11@dxpl.pdx.osdl.net>
	<20050526.155401.18310361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bridge@osdl.org
Return-path: <bridge-bounces@lists.osdl.org>
To: <shemminger@osdl.org>, "David S. Miller" <davem@davemloft.net>
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Sender: bridge-bounces@lists.osdl.org
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

I have a question about using the 802.1d driver with a switch.  I have a 
managed switch
which connects to the Xscale MAC using a Reverse MII interface.

It seems that the 802.1d bridge puts the interface into promiscuous mode and 
needs multiple
ethernet devices to work with.  Can it work with a single ethernet device 
which is connected
to a BCM5338 ( broadcomm 8 port switch chip ).

I understand that I would have to change the STP configuration component to 
write to the
broadcomm chip.

The chip supports direct memory mapped I/O of BPDU's using polled 
xmite/recieve using
a SPI interface.  Since I use a soft SPI stack, I cannot go faster than 
2MHz. Besides this
is a serial interface.

Suggestion, comments on both choices are highly appreciated.  I am working 
in a custom
enviornment with main objective of detecting loops in a cascade of switches. 
The physical
interconnect of the switches could be linear, tree, star or graph topology.

Also, the spanning tree needs to reconverge when switches are 
connected/disconnected.
Since there are no interrupts from the BCM5338, most of the implementation 
would be
based of polling.  Maybe, a forwarding delay of 5s should work as this is a 
LAN environment.

--
Atul
Linux Engineer 
