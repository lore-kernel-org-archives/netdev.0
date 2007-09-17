From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 7/7] CAN: Add documentation
Date: Mon, 17 Sep 2007 15:57:18 -0700
Message-ID: <20070917155718.ee2cc803.randy.dunlap@oracle.com>
References: <20070917100321.18347.0@janus.isnogud.escape.de>
	<20070917100441.18347.7@janus.isnogud.escape.de>
	<20070917103003.109ae665.randy.dunlap@oracle.com>
	<ygfps0hrqj5.fsf@janus.isnogud.escape.de>
	<1190061421.2995.44.camel@chaos>
	<ygflkb5rp9d.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:25284 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754170AbXIQW6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 18:58:52 -0400
In-Reply-To: <ygflkb5rp9d.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17 Sep 2007 22:49:34 +0200 Urs Thuermann wrote:

> Thomas Gleixner <tglx@linutronix.de> writes:
> 
> > Please do, having the patch in mail makes it easier to review and to
> > comment.
> 
> OK, here it is:

Just a few more minor changes...  Thanks again.


> +3. Socket CAN concept
> +---------------------
> +
> +  As described in chapter 2 it is the main goal of Socket CAN to
> +  provide a socket interface to user space applications which builds
> +  upon the Linux networklayer. In contrast to the commonly known

                    network layer.

> +  TCP/IP and ethernet networking, the CAN bus is a broadcast-only(!)
> +  medium that has no MAC-layer addressing like ethernet. The CAN-identifier
> +  (can_id) is used for arbitration on the CAN-bus. Therefore the CAN-IDs
> +  have to be chosen uniquely on the bus. When designing a CAN-ECU
> +  network the CAN-IDs are mapped to be sent by a specific ECU.
> +  For this reason a CAN-ID can be treated best as a kind of source address.
> +
> +  3.2 loopback
> +
> +  As known from other networking concepts the data exchanging
> +  applications may run on the same or different nodes without any
> +  change (except for the according addressing information):
> +
> +         ___   ___   ___                   _______   ___
> +        | _ | | _ | | _ |                 | _   _ | | _ |
> +        ||A|| ||B|| ||C||                 ||A| |B|| ||C||
> +        |___| |___| |___|                 |_______| |___|
> +          |     |     |                       |       |
> +        -----------------(1)- CAN bus -(2)---------------
> +
> +  To ensure that application A receives the same information in the
> +  example (2) as it would receive in example (1) there is need for
> +  some kind of local loopback on the appropriate node.
> +
> +  The Linux network devices (by default) just can handle the
> +  transmission and reception of media dependent frames. Due to the
> +  arbritration on the CAN bus the transmission of a low prio CAN-ID
> +  may be delayed by the recepition of a high prio CAN frame. To

                           reception

> +  reflect the correct* traffic on the node the loopback of the sent
> +  data has to be performed right after a successful transmission. If
> +  the CAN network interface is not capable of performing the loopback for
> +  some reason the SocketCAN core can do this task as a fallback solution.
> +  See chapter 6.2 for details (recommended).
> +
> +  The loopback functionality is enabled by default to reflect standard
> +  networking behaviour for CAN applications. Due to some requests from
> +  the RT-SocketCAN group the loopback optionally may be disabled for each
> +  separate socket. See sockopts from the CAN RAW sockets in chapter 4.1.
> +
> +  * = you really like to have this when you're running analyser tools
> +      like 'candump' or 'cansniffer' on the (same) node.
> +

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
