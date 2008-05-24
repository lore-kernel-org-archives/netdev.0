From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [Bugme-new] [Bug 10767] New: Seg Fault Instead of Swapping
Date: Sat, 24 May 2008 11:57:51 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805241156120.27780@wrl-59.cs.helsinki.fi>
References: <bug-10767-10286@http.bugzilla.kernel.org/>
 <20080521105747.215be17d.akpm@linux-foundation.org>
 <cf4145200805211140o3b2287dcsc57f8a78aa48a99d@mail.gmail.com>
 <Pine.LNX.4.64.0805212310050.7747@wrl-59.cs.helsinki.fi>
 <cf4145200805211345y3b00d209o58e11a7b553cdfc6@mail.gmail.com>
 <Pine.LNX.4.64.0805231302410.16829@wrl-59.cs.helsinki.fi>
 <cf4145200805230906k34a0452at773e840b791e6b0a@mail.gmail.com>
 <cf4145200805231024w2e735fb8ifecf7e2e1bab5957@mail.gmail.com>
 <Pine.LNX.4.64.0805232043030.25097@wrl-59.cs.helsinki.fi>
 <cf4145200805231126y401c2454w97e5305346aa8acd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: Brian Vowell <brian.vowell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52935 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752878AbYEXI55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2008 04:57:57 -0400
In-Reply-To: <cf4145200805231126y401c2454w97e5305346aa8acd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 May 2008, Brian Vowell wrote:

> > Aha, it seems you got TCP into the invalid state which I recently added
> > check for :-), I'll try to figure out how that could still happen (I think
> > I tried to find such code path already earlier but it seems that there's
> > still something I've overlooked). Though this is not directly going to
> > cause the 2539 WARNING, yet it could, after some other (probably rare
> > condition) possibly lead to that as well if this invariant is assumed to
> > hold while doing some state manipulation elsewhere in TCP (though I
> > think that's not too likely). In case you don't see them too often, you
> > can well continue with the patch in order to find the cause for 2539 as
> > well (and just ignore those occassional net/ipv4/tcp_input.c:3297 ones for
> > now).
> 
> 
> Do you want me to continue emailing these traces as they appear in my logs?

...Yes, in case you get something different than the WARNING at 3297.
I have at least one suspect already which could lead to that 3297 :-).

-- 
 i.
