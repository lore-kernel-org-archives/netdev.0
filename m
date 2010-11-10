From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [RFC 0/3] MPEG2/TS drop analyzer iptables match extension
Date: Wed, 10 Nov 2010 12:02:20 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1011081229390.13163@ask.diku.dk>
References: <Pine.LNX.4.64.1010191608080.18708@ask.diku.dk>
 <alpine.LNX.2.01.1011040113270.8604@obet.zrqbmnf.qr>
 <Pine.LNX.4.64.1011040953590.19565@ask.diku.dk>
 <alpine.LNX.2.01.1011041121170.16551@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Solvik Blum <solvik.blum@smartjog.com>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1011041121170.16551@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 4 Nov 2010, Jan Engelhardt wrote:
> On Thursday 2010-11-04 10:20, Jesper Dangaard Brouer wrote:
>> On Thu, 4 Nov 2010, Jan Engelhardt wrote:
>>>
>>> This now lives in the mp2t branch (since NFWS already actually) of xt-a,
>>> and I have taken the liberty to start updating it to higher standards.
>>> Please watch that branch, as I don't have any MPEG equipment around me
>>> to do runtime tests.
>>
>> Jan, I would actually like to maintain the source via my own git tree. And I
>> would gladly accept your patches against that tree.
>
> I do not mind who is hosting what parts, as git repos can be
> transferred easily, but I strongly suggest not to decouple xt_mp2t
> from (any clone of) the xtables-addons structure base, because doing
> so would bring you back to square one with regard to maintenance.
>
> I recognize you may dislike splitting up the IPTV codebase, so I
> propose that you make use of submodules, and have an Xt-a clone as
> one submodule. That would allow merging in both directions.

Well, I'm ready to maintain the module my self.  I know we talked (during 
Netfilter Workshop) about putting the module into the Xtables-addons 
git-tree, because the project had stalled.

But things have changed! - I now have some people/developers interested in 
the project, thus I'm taking an active maintainer role instead.

My plan is to keep the module "compatible" with the Xtables-addon build 
system.  Thats why I make my module use your compat_* system from xt-a.
This way you can easier copy the module into you tree, if I fail to 
maintain the module...

I have looked at your improvements in the "mp2t" branch of you tree. I'll 
integrate those changes/improvement in my tree, and give you the author 
credits in my tree.

(ps. this email got delayed on my postponed email outbox, sorry.  Have 
already had some offlist discussions with Jan)

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
