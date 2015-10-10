From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 00/13] rocker: add support for multiple worlds
Date: Sat, 10 Oct 2015 09:35:06 +0200
Message-ID: <20151010073506.GA2119@nanopsycho.orion>
References: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
 <CAE4R7bAymAKeKBOwPP11QDvBYR-iCMg3VD_7qBZH+n_+f-x9WA@mail.gmail.com>
 <20151006073018.GA2165@nanopsycho.orion>
 <CAE4R7bDTF9tt-G+9vXQ-jfkHVg=sL06DPzmA6gfSWvhDEz95OQ@mail.gmail.com>
 <20151007060355.GA2152@nanopsycho.orion>
 <CAE4R7bAHh-vc08Jfq8Q-OZoUCFQhfvOq2+STc_X0eM0q-8fzJw@mail.gmail.com>
 <20151007173956.GI2152@nanopsycho.orion>
 <20151009143636.GI2161@nanopsycho.orion>
 <CAE4R7bC9o641hJV3rN68C1iutNAZ3kdtd=S3_9B5SV17in63ag@mail.gmail.com>
 <20151010072115.GC1990@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>, Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Laight <David.Laight@aculab.com>,
	john fastabend <john.fastabend@gmail.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35597 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbbJJHfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 03:35:10 -0400
Received: by wicge5 with SMTP id ge5so94584878wic.0
        for <netdev@vger.kernel.org>; Sat, 10 Oct 2015 00:35:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20151010072115.GC1990@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Oct 10, 2015 at 09:21:15AM CEST, jiri@resnulli.us wrote:

<snip>

>>
>>I had just re-run the tests against net-next before submitting the
>>ageing_time patchset and everything passes.
>>
>>Are you using a namespace or a VM for host1?  Either one should work.
>>
>>This would be a bad test, as the kernel will loop the traffic and the
>>offload device will not see it:
>>
>>DUT:sw1p1 (11.0.0.1/24) <-------->DUT:sw1p2(11.0.0.2/24)
>
>For this test, I'm using 2 namespaces on baremetal.
>
>I just discovered very odd behaviour.
>I'm using 2 scripts so setup basic bridging scenario:
>On host, I use "setupns.sh": http://pastebin.com/f9igGxgV
>On vm, I use "setbr.sh" http://pastebin.com/Ycyyj8PK
>
>Now when I turn on the vm and do:
>vm# ./setbr.sh
>host# ./setupns.sh
>It works fine.
>
>But when I execute these if reverse order:
>host# ./setupns.sh
>vm# ./setbr.sh
>It does not work.

Hmm, I compiled git master qemu and with that, it works fine. I guess
that was some but in my previous qemu version. Sorry about the fuzz :/
