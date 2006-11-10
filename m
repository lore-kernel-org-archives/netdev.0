From: Michael Stone <mstone@mathom.us>
Subject: Re: [PATCH 4/4] skge: version 1.9
Date: Thu, 09 Nov 2006 19:34:50 -0500
Message-ID: <20061110003448.GE2667@mathom.us>
References: <20061005224949.456192755@osdl.org>
 <20061005225209.769741968@osdl.org> <20061107132506.GS2667@mathom.us>
 <200611072028.kA7KSQZt032181@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms046pub.verizon.net ([206.46.252.46]:56992 "EHLO
	vms046pub.verizon.net") by vger.kernel.org with ESMTP
	id S1424314AbWKJAfN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 19:35:13 -0500
Received: from osgiliath.mathom.us ([71.246.251.8])
 by vms046.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0J8H009OHOA6GLXA@vms046.mailsrvcs.net> for
 netdev@vger.kernel.org; Thu, 09 Nov 2006 18:34:54 -0600 (CST)
In-reply-to: <200611072028.kA7KSQZt032181@death.nxdomain.ibm.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 07, 2006 at 12:28:26PM -0800, Jay Vosburgh wrote:
>	Can you provide some bonding configuration details?  Which mode,
>options, etc, as well as the relevant bits from dmesg (you can send it
>to me privately if it's huge)?  

I think I sent another message that I'm just doing 
ifenslave bond0 eth2
ifenslave bond0 eth3
with no particular options set. The application is a network sniffer, 
and the cards are forced to 1000Mbps/full duplex because the other end 
doesn't negotiate. What's the relevant part of dmesg?

Mike Stone
