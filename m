From: Marc Aurele La France <tsi@ualberta.ca>
Subject: Re: RFC: MTU for serving NFS on Infiniband
Date: Thu, 26 Aug 2010 08:43:42 -0600 (Mountain Daylight Time)
Message-ID: <alpine.WNT.2.00.1008260835020.2008@cluij.ucs.ualberta.ca>
References: <alpine.LNX.2.00.1008230842290.9325@abcyxhiz.aict.ualberta.ca> <20100823080543.319143e3@nehalam> <alpine.WNT.2.00.1008240856170.2000@cluij.ucs.ualberta.ca> <1282672647.2302.15.camel@achroite.uk.solarflarecom.com> <alpine.WNT.2.00.1008241338470.1132@cluij.ucs.ualberta.ca>
 <1282688441.22839.34.camel@localhost> <20100824153920.63360072@s6510> <alpine.WNT.2.00.1008251408520.632@cluij.ucs.ualberta.ca> <1282823827.2476.663.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="633328-19643-1282833823=:2008"
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.srv.ualberta.ca ([129.128.5.19]:59663 "EHLO
	mail9.srv.ualberta.ca" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753918Ab0HZOov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 10:44:51 -0400
In-Reply-To: <1282823827.2476.663.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--633328-19643-1282833823=:2008
Content-Type: TEXT/PLAIN; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8BIT

On Thu, 26 Aug 2010, Eric Dumazet wrote:
> Le jeudi 26 août 2010 à 05:40 -0600, Marc Aurele La France a écrit :

>> Steady now.  There's no need to YELL nor be arrogant.  You and I both know
>> there's a place for NFS over UDP.  That's not changing any time soon.  While
>> I'm aware of the issue you brought up, it is separate from the one at hand in
>> this discussion.

>> I do want to thank you, however, for reminding me of TCP.  It's something
>> 20/20 hindsight says I should have checked out before starting this thread.
>> Logistically, it'll be a few days before I can do so though.  If that allows
>> me to increase the MTU all the way up to 65520, then this UDP thing will
>> likely remain unresolved.

> Unfortunately, your infiniband device lacks NETIF_F_SG support.

Oh, the device itself probably has something similar, but ipoib 
(IP-over-Infiniband) doesn't export that capability.

> MTU a bit larger than PAGE_SIZE-overhead will need high order
> allocations ?

Right.  And a 65520 MTU allocates sk_buff's with 128K contiguous payloads.

Marc.

+----------------------------------+----------------------------------+
|  Marc Aurele La France           |  work:   1-780-492-9310          |
|  Academic Information and        |  fax:    1-780-492-1729          |
|    Communications Technologies   |  email:  tsi@ualberta.ca         |
|  352 General Services Building   +----------------------------------+
|  University of Alberta           |                                  |
|  Edmonton, Alberta               |    Standard disclaimers apply    |
|  T6G 2H1                         |                                  |
|  CANADA                          |                                  |
+----------------------------------+----------------------------------+
--633328-19643-1282833823=:2008--
