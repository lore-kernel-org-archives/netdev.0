From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: TCP funny-ness when over-driving a 1Gbps link (and wifi)
Date: Thu, 26 May 2011 09:28:16 -0600
Message-ID: <4DDE7190.3080503@genband.com>
References: <4DD59DF2.2070707@candelatech.com>	 <20110519161827.2ba4b40e@nehalam> <4DD5A5CD.7040303@candelatech.com>	 <4DD5AAFC.8070509@candelatech.com> <1305849940.8149.1122.camel@tardy>	 <4DD5B202.7080701@candelatech.com> <1305851079.8149.1127.camel@tardy>	 <4DD5B7B3.2000505@candelatech.com> <1305852377.8149.1133.camel@tardy> <4DD5E270.3030209@candelatech.com> <4DD6DE1C.8090607@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og106.obsmtp.com ([64.18.2.165]:47442 "EHLO
	exprod7og106.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932445Ab1EZP2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 11:28:50 -0400
In-Reply-To: <4DD6DE1C.8090607@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/20/2011 03:33 PM, Ben Greear wrote:

> I tried a different test today: 3 TCP connections between two
> wifi station interfaces (using ath9k). Each connection is
> endpoint configured to send 100Mbps of traffic to the peer.
>
> With a single connection, it does OK (maybe 250ms round-trip time max).
> With 3 of them running, round-trip user-space to user-space latency
> often goes above 3 seconds.

<snip>

> So, seems a general issue with over-driving links with multiple TCP
> connections. Doesn't seem like a regression, and probably not really
> a bug, but maybe the buffer-bloat project will help this sort of
> thing...

Given that one rule of thumb for the send buffer size is twice the 
bandwidth delay product, it seems clear that on a wifi connection 3 
seconds worth of buffering is excessive.  I think I'd classify that as a 
bug.

Chris


-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
