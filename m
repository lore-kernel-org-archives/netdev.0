From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Q: need effective backlog for listen()
Date: Mon, 08 Dec 2014 07:18:21 -0800
Message-ID: <1418051901.15618.46.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5485ACC9020000A100018394@gwsmtp1.uni-regensburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ulrich Windl <Ulrich.Windl@rz.uni-regensburg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:48349 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756042AbaLHPSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 10:18:25 -0500
Received: by mail-ig0-f171.google.com with SMTP id z20so2847362igj.16
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2014 07:18:24 -0800 (PST)
In-Reply-To: <5485ACC9020000A100018394@gwsmtp1.uni-regensburg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-12-08 at 13:51 +0100, Ulrich Windl wrote:
> (not subscribed to the list, plese keep me on CC:)
> 
> Hi!
> 
> I have a problem I could not find the answer. I suspect the problem
> arises from Linux derivating from standard functionality...
> 
> I have written a server that should accept n TCP connections at most.
> I was expecting that the backlog parameter of listen will cause extra
> connection requests either
> 1) to be refused
> or
> 2) to time out eventually
> 
> (The standard seems to say that extra connections are refused)
> 
> However none of the above see ms true. Even if my server delays
> accept()ing new connections, no client ever sees a "connection
> refused" or "connection timed out". Is there any chance to signal the
> client that no more connections are accepted at the moment?

This 'standard' makes no sense to me, in light of SYNFLOOD attacks.

It actually makes SYNFLOOD attacks very effective.

Have you tried to disable syncookies for a start ?
