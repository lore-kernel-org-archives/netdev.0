From: Julie Sullivan <kernelmail.jms@gmail.com>
Subject: Re: [patch] skbuff: use kfree_skb() instead of kfree()
Date: Wed, 20 Jul 2011 22:03:52 +0100
Message-ID: <CAAVPGOMMeMCPdpUJPtWNnqgxSH3oT=8mnyYzio41mVPCFy2QUg@mail.gmail.com>
References: <20110720072343.GF6445@shale.localdomain>
	<20110720072549.GG6445@shale.localdomain>
	<1311147723.3113.116.camel@edumazet-laptop>
	<20110720080109.GH6445@shale.localdomain>
	<1311150084.2338.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<Pine.LNX.4.64.1107201035270.24382@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Dan Carpenter <error27@gmail.com>, Shirley Ma <xma@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:50306 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810Ab1GTVDx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 17:03:53 -0400
In-Reply-To: <Pine.LNX.4.64.1107201035270.24382@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> > > Also, dont forget to say its a patch for net-next-2.6
>> >
>> > If you're using linux-next, is there a way to tell which tree a
>> > patch came from? =A0Obviously in this case it's core networking, b=
ut
>> > in other cases how does that work?
>>
>> In this particular case, David will know for sure since patch is ver=
y
>> recent, but I wanted to make a general advice.
>>
>> Keep in mind David has to review dozens of patches _per_ day, so net=
dev
>> related patches need some extra cooperation from submitters to help =
the
>> maintainer.
>>
>> This extra cooperation means to test the patch on either net-next-2.=
6 or
>> net-2.6 tree ;)
>
> Maybe there is some way to integrate such a suggestion in get_maintai=
ners
> or checkpatch? =A0Otherwise, those who work on the code in a more bre=
adth
> first way don't have much chance of knowing or remembering this advic=
e.
>
> julia

I think Julia's observation is really on the nail, I wish there were
some way of doing this? If new or random testers or reviewers out
there aren't tracking/following a particular tree/project already -
i.e. if they don't _know_ beforehand, aren't they going to just assume
using linux-next is correct (at least that's what I do)?
Knowing what branch to most productively test patches against
beforehand might encourage more testers and submissions and also could
make maintainer's jobs a bit easier.

Cheers
Julie
