From: Chris Friesen <chris.friesen@genband.com>
Subject: any way to let host act as TCP server OR client on same IP/port?
Date: Wed, 13 Jul 2011 10:30:52 -0600
Message-ID: <4E1DC83C.3020506@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og109.obsmtp.com ([64.18.2.171]:37917 "EHLO
	exprod7og109.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754596Ab1GMQbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 12:31:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been asked an interesting question about TCP.  We have some people 
that want to set up a TCP socket that can listen for connections on a 
given IP/port, but also initiate connections from that same IP/port. 
(Only one at a time, of course.)

The TCP state machine seems to allow this (moving from LISTEN to 
SYN_SENT) but it's not a normal transition.

Is there any way to do this using the socket API?

I thought up a hack whereby we could use NFQUEUE to detect an incoming 
SYN and delay it while we call listen() on the socket.  Is there any 
better way to do this?

Thanks,

Chris


-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
