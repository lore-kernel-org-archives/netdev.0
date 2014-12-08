From: "Ulrich Windl" <Ulrich.Windl@rz.uni-regensburg.de>
Subject: Antw: Re: Q: need effective backlog for listen()
Date: Mon, 08 Dec 2014 17:31:10 +0100
Message-ID: <5485E05E020000A1000183B4@gwsmtp1.uni-regensburg.de>
References: <5485ACC9020000A100018394@gwsmtp1.uni-regensburg.de>
 <1418051901.15618.46.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrzmta2.uni-regensburg.de ([194.94.155.52]:48735 "EHLO
	rrzmta2.uni-regensburg.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754953AbaLHQbL convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:2:1>);
	Mon, 8 Dec 2014 11:31:11 -0500
Received: from rrzmta2.uni-regensburg.de (localhost [127.0.0.1])
	by localhost (Postfix) with SMTP id A21EC52E5E
	for <netdev@vger.kernel.org>; Mon,  8 Dec 2014 17:31:10 +0100 (CET)
Received: from gwsmtp1.uni-regensburg.de (gwsmtp1.uni-regensburg.de [132.199.5.51])
	by rrzmta2.uni-regensburg.de (Postfix) with ESMTP id 7AA1C529B9
	for <netdev@vger.kernel.org>; Mon,  8 Dec 2014 17:31:10 +0100 (CET)
In-Reply-To: <1418051901.15618.46.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> Eric Dumazet <eric.dumazet@gmail.com> schrieb am 08.12.2014 um 16:18 in
Nachricht <1418051901.15618.46.camel@edumazet-glaptop2.roam.corp.google.com>:
> On Mon, 2014-12-08 at 13:51 +0100, Ulrich Windl wrote:
>> (not subscribed to the list, plese keep me on CC:)
>> 
>> Hi!
>> 
>> I have a problem I could not find the answer. I suspect the problem
>> arises from Linux derivating from standard functionality...
>> 
>> I have written a server that should accept n TCP connections at most.
>> I was expecting that the backlog parameter of listen will cause extra
>> connection requests either
>> 1) to be refused
>> or
>> 2) to time out eventually
>> 
>> (The standard seems to say that extra connections are refused)
>> 
>> However none of the above see ms true. Even if my server delays
>> accept()ing new connections, no client ever sees a "connection
>> refused" or "connection timed out". Is there any chance to signal the
>> client that no more connections are accepted at the moment?
> 
> This 'standard' makes no sense to me, in light of SYNFLOOD attacks.
> 
> It actually makes SYNFLOOD attacks very effective.
> 
> Have you tried to disable syncookies for a start ?

No, I tries to temporarily close the listening socket. My priority is not to overload the server with connections. At the sime time I _want_ that the clients see that the server resfuses connections. Before you wonder: The client will actually be a load balancer.
