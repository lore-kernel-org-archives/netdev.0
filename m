From: Gabriel Barazer <gabriel@oxeva.fr>
Subject: Re: [2.6.24.3][net] bug: TCP 3rd handshake abnormal timeouts
Date: Sun, 16 Mar 2008 17:24:38 +0100
Message-ID: <47DD49C6.8040400@oxeva.fr>
References: <47DB28E9.4050309@oxeva.fr> <20080315065739.GL8953@1wt.eu> <20080315065849.GA11817@1wt.eu> <47DB8D1C.7020006@oxeva.fr> <20080315085527.GA6239@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.reagi.com ([195.60.188.80]:39240 "EHLO mail.reagi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753367AbYCPQYt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Mar 2008 12:24:49 -0400
In-Reply-To: <20080315085527.GA6239@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On 03/15/2008 9:55:27 AM +0100, Willy Tarreau <w@1wt.eu> wrote:
> On Sat, Mar 15, 2008 at 09:47:24AM +0100, Gabriel Barazer wrote:
> 
> Feel free to repost the whole issue overthere (along with your new tests)
> if you don't get useful replies in a few days.
> 
>> By the way thanks for replying. It's hard to explain and describe a 
>> problem when you know people will ask you hundreds of questions related 
>> to application-level problems, or not reply because web/mysql problems 
>> are so common and generally not related to any kernel issue.
> 
> What caught my attention was the usual "3s delay", which is purely TCP
> and application-independant.
> 
> 
>>> Also, you say you have netfilter with conntrack. Is this on the client ?
>>> If so, you should try disabling it to rule out any possible bug in the
>>> connection tracking.
>> I have the conntrack  on both the client and server, and unfortunately 
>> can't disable it now on the client (I use it only for the REDIRECT 
>> target on a precise destination address and port, not MySQL related), 
>> however I will test today and disable it on the server, after I get some 
>> sleep (although I think the issue is on the client).
> 
> I'm sure it's a client issue too, that's why it would be reasonable to
> be able to try without conntrack. Can't you use a TCP proxy instead of
> REDIRECT ? Also, you said that you also noticed the same behaviour in
> other environments, maybe there you can disable conntrack ?

I was able to reproduce the bug multiple times without conntrack nor 
netfilter on the client and the server(I recompiled the kernel disabling 
the entire netfilter subsystem). The 3-second problem still occurs so we 
can completely rule out contrack-related bugs.

What can we do and test next?

Gabriel
