From: Michael Stone <mstone@mathom.us>
Subject: Re: [PATCH 4/4] skge: version 1.9
Date: Tue, 07 Nov 2006 08:25:07 -0500
Message-ID: <20061107132506.GS2667@mathom.us>
References: <20061005224949.456192755@osdl.org>
 <20061005225209.769741968@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms044pub.verizon.net ([206.46.252.44]:25918 "EHLO
	vms044pub.verizon.net") by vger.kernel.org with ESMTP
	id S932624AbWKGNZZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 08:25:25 -0500
Received: from osgiliath.mathom.us ([71.246.251.8])
 by vms044.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0J8D00E2O3XYZM63@vms044.mailsrvcs.net> for
 netdev@vger.kernel.org; Tue, 07 Nov 2006 07:25:10 -0600 (CST)
In-reply-to: <20061005225209.769741968@osdl.org>
To: Stephen Hemminger <shemminger@osdl.org>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The skge 1.9 patch is looking good on older syskonnect fiber cards.  
Stability issues seem to be taken care of and performance is good. There 
are some strange interactions with bonding, however. If I try to put 
both interfaces of an sk-9844 into a bonded interface, I only see 
traffic from one of them. If I try to config the bonded interface down, 
the system hangs. If I tcpdump either of the individual interfaces 
(before bonding them) I see all the expected traffic.

Mike Stone
