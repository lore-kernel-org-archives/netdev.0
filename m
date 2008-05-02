From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: 2.6.25 crash: EIP: [<c02e2f14>] xfrm_output_resume+0x64/0x100 ss:esp 0068:c03a1e5c
Date: Fri, 2 May 2008 14:26:14 +0200
Message-ID: <BAY103-DAV594320AC93E33D7335927B2DA0@phx.gbl>
References: <E1Jrtxr-0004in-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s13.bay0.hotmail.com ([65.54.246.149]:56568 "EHLO
	bay0-omc2-s13.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756921AbYEBMZH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 08:25:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:

> Marco Berizzi <pupilla@hotmail.com> wrote:
>> Just few minutes ago, another 2.6.25 crash
>> with this message:
>> 
>> EIP: [<c028000a>] netif_rx+0x6a/0xd0 SS:ESP 0068:c039f868
>> 
>> http://80.204.235.230/4.jpg
> 
> OK, the xfrm_output_resume trail revealed nothing.  Combined
> with this crash however, it would appear that you've got a problem
> with live skbs being freed.  Unfortunately such problems are
> difficult to track down.
> 
> Perhaps you could enable SLAB debugging to see if we can get
> closer to the culprit?

Yes indeed, I will try next monday.

> Alternatively you could try a git bisection.

Yes, but it could take forever... :-((
As I said, I have removed the sfq and htb modules,
and I would like to wait one week to see if these
boxes will crash. I have 8 linux boxes running 2.6.25
with the same .config and only the two with htb/sfq
qdisc are crashing. Just few minutes ago I have seen
this message forwarded to netdev by David Miller:

Re: PROBLEM: kernel lockup while changing TC rules

it is talking about htb/sfq. Maybe it is related.
 
> Unless we have a way of reproducing this there isn't a lot more
> that we can do I'm afraid.

thanks anyway Herbert.
