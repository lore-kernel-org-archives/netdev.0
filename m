From: Rick Jones <rick.jones2@hp.com>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 09 Sep 2008 10:54:02 -0700
Message-ID: <48C6B83A.3080501@hp.com>
References: <48C59F75.6030504@redhat.com> <48C5A9A9.9040503@hp.com>	<48C6052D.2080203@redhat.com> <48C6A553.2070901@hp.com> <732BEAC4-63ED-413B-8BE6-E194DFA6DD7B@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>, Netdev <netdev@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:1520 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753954AbYIIRyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 13:54:06 -0400
In-Reply-To: <732BEAC4-63ED-413B-8BE6-E194DFA6DD7B@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> If the applications are sending streams of logically unrelated sends  
>> down the same socket, then setting TCP_NODELAY is IMO fine.  Where  it 
>> isn't fine is where these applications are generating their  logically 
>> associated data in two or more small sends.  One send per  message 
>> good. Two sends per message bad.
> 
> 
> Can the same be said of the Linux kernel's RPC client, which uses  
> MSG_MORE and multiple sends to construct a single RPC request on a TCP  
> socket?

That drifts away from Nagle and into my (perhaps old fuddy-duddy) belief 
in minimizing the number of system/other calls to do a unit of work, and 
degrees of "badness:)"

rick jones
