From: Gagan Arneja <gaagaan@gmail.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 22:01:37 -0700
Message-ID: <4643F8B1.5030803@gmail.com>
References: <464370BA.3020907@hp.com> <20070510.133216.95506791.davem@davemloft.net> <46438568.1020403@hp.com> <20070510.140251.02302242.davem@davemloft.net> <46438B1D.1050802@gmail.com> <20070510192814.5b71d01c@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gagan Arneja <gaagaan@gmail.com>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	vladislav.yasevich@hp.com, ian.mcdonald@jandi.co.nz,
	krkumar2@in.ibm.com, johnpol@2ka.mipt.ru, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gretel.pobox.com ([208.58.1.197]:50270 "EHLO gretel.pobox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753395AbXEKFDz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 01:03:55 -0400
Received: from sceptre.pobox.com (sceptre.pobox.com [207.106.133.20])
	by gretel.pobox.com (Postfix) with ESMTP id 2A26A60F2685
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 01:03:02 -0400 (EDT)
In-Reply-To: <20070510192814.5b71d01c@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > If you have braindead slow hardware,
 > there is nothing that says your start_xmit routine can't do its own
 > coalescing.  The cost of calling the transmit routine is the 
responsibility
 > of the driver, not the core network code.

Yes, except you very likely run the risk of the driver introducing 
latency. The problem is prevalent enough that one can argue for a fix (a 
better one at that) higher up. And it's not all that high up that we 
need to get completely paranoid about it.

 > --
 > Stephen Hemminger <shemminger@linux-foundation.org>
 >

--
Gagan

