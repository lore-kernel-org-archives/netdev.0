From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH,pktgen] account for preamble and inter-packet gap
Date: Mon, 29 Nov 2004 17:16:13 +0100
Message-ID: <16811.19277.594137.939120@robur.slu.se>
References: <20041128213251.GA9330@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041128213251.GA9330@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Lennert Buytenhek writes:

 > If you account for the Frame Check Sequence when computing bandwidth
 > stats, it's only fair that you count the preamble and inter-packet gap
 > as well.  Suggested patch attached.

 Well from pktgen TX view we don't know what the layer under us will do. 
 We simply deliver packets and hope those get transmitted but we are not
 100% sure neither about ipg or preample. We don't even know that packets 
 are seen on the wire. We use to verify this in our specific HW setup. 
 So what trusted statistics can we give? 

 I've heard some boxes that didn't do the ipg correctly. Don't know what NIC 
 this was. We can only estimate stats at the point where we are delivering 
 packets. Other devices has "true" L2 stats.
 
 OK. Adding FCS yes kinda compromise and maybe was wrong in this aspect.

 Also we should think of calculation should work with link other link
 link layers not only ethernet.
 
 The only solution I can think of is of having a selectable option in 
 the config for output stats. To support different L2 layers and with  
 warning if we are "predicting" L2 statistics. Feel free to extend your
 patch.

						--ro
 
 
