From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: ARP Spoofing
Date: Wed, 02 May 2007 16:45:48 -0400
Message-ID: <4638F87C.2090000@hp.com>
References: <4638CDED.4020100@cs.byu.edu> <4638DEB9.90608@hp.com> <4638F6E8.3060609@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Topher Fischer <javert42@cs.byu.edu>, netdev@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:34937 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751153AbXEBUpv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 16:45:51 -0400
In-Reply-To: <4638F6E8.3060609@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Friesen wrote:
> Vlad Yasevich wrote:
> 
>> If by arp spoofing you mean receiving arp replies from multiple
>> sources and
>> trusting all of them, then I haven't seen anything.
>>
>> I don't know the history as to why nothing has has been done.
> 
> This concept is a valuable tool to allow for fast publishing of IP
> address takeover in redundant-server situations.
> 
> There are ways in which it can be misused, but that doesn't make it an
> invalid technique.
> 

Yes, but when some bozo on the network misconfigures his system and
steals the IP of the default router, all hell breaks lose.

BSD is nice enough to tell you that a duplicate ARP response has been
received and gives you nobs to be able to turn this on and off.

BTW, the same issue came in IPv6, where a malicious user can cause
all sorts of nasty things on the network and the solution for that was SEND
(RFC 3971).  So at least the same problem can be solved in IPv6.

-vlad
