From: Brad Hards <bhards@bigpond.net.au>
Subject: Re: PF_PACKET??
Date: Fri, 19 Apr 2002 09:02:32 +1000
Sender: linux-net-owner@vger.kernel.org
Message-ID: <200204190902.32603.bhards@bigpond.net.au>
References: <Pine.LNX.4.33L2.0204181210020.30005-100000@pali.cps.cmich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <linux-net-owner@vger.kernel.org>
To: Ish Rattan <ishwar@pali.cps.cmich.edu>, <linux-net@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.33L2.0204181210020.30005-100000@pali.cps.cmich.edu>
List-Id: netdev.vger.kernel.org

On Fri, 19 Apr 2002 02:13, Ish Rattan wrote:
> Does any one have a complete client/server type program or tutotial on
> using PF_PACKET to by pass the TCP/IP stack in the kernel? I can't seem
> to find a sample and hence subscribed to this list to ask for
> pointers.
Possibly the wrong question. I take it that you want to avoid using the kernel 
support for some reason, possibly portability. In that case, you should 
consider a couple of libraries 
-pcap, which does packet capturing
    http://www.tcpdump.org/
- libnet, which does packet assembly
    http://www.packetfactory.net/libnet/

They basically insulate you from the joys of packet filtering.

There are several applications that show how this works (eg tcpdump, zcip, 
snort), plus they both have decent docs and sample apps.

HTH

Brad


