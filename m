From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v5 0/4] return offloaded stats as default and
 expose original sw stats
Date: Fri, 8 Jul 2016 07:05:01 -0700
Message-ID: <CAJieiUhUSMJOLLM52P_0bDVtCFCVRVe0gEdLvwBCTgJKUQyE1g@mail.gmail.com>
References: <20160623113508.GE2060@nanopsycho.orion> <CACcJQnTfr5n75q48aJQ3bwzfCd9oThTCHcR_qWG7R9aV13pOQw@mail.gmail.com>
 <20160623154038.GH2060@nanopsycho.orion> <CAJieiUjsMHdTbhGqyo+8ys7S5QZ9KYvTY+LDC-bbo6dRk3FBRw@mail.gmail.com>
 <20160626093334.GA1984@nanopsycho.orion> <577019B0.9080708@cumulusnetworks.com>
 <20160626181546.GA1938@nanopsycho.orion> <CAJieiUgjfO-J_uUVV6VVS8ar1Fg8wMJwcmaemu==Su3DospLTA@mail.gmail.com>
 <20160627065102.GC2058@nanopsycho.orion> <CAJieiUh_2B3y78Fa7Oqwy6oc3WaJrNJk+h95tjT3=ojwXfGccQ@mail.gmail.com>
 <20160627131158.GE2058@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Nogah Frankel <nogahf@mellanox.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Yotam Gigi <yotamg@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>, sd@queasysnail.net,
	eranbe@mellanox.com, Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <edumazet@google.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	David Ahern <dsa@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:35454 "EHLO
	mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932614AbcGHOFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 10:05:03 -0400
Received: by mail-vk0-f45.google.com with SMTP id v6so56959493vkb.2
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 07:05:02 -0700 (PDT)
In-Reply-To: <20160627131158.GE2058@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 6:11 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Mon, Jun 27, 2016 at 03:02:31PM CEST, roopa@cumulusnetworks.com wrote:

[snip]

>>
>>The point of the stats api is to bring all stats together.
>>ethtool stats are very valuable. so there is no point leaving them out.
>>they will be in here sooner or later.
>>
>>when there is already a discussion of moving ethtool to netlink,..i am not sure
>>I understand the hesitation on moving ethtool stats to netlink.
>
> It's not well defined. That's the issue. It's "debugfs"...
>
>
>>
>>>
>>>
>>> This patchset uses well defined values for slowpatch(/sw/cpu) stats.
>>> That is I believe the only way to do this.
>>>
>>
>>It seems to be your preferred way. I don't think it is the only way to
>>do it. It can very well be part of the nested
>>breakdown stats i am talking about.
>
> We are using existing well-defined structure. Very easy and clean.

sure, it is well-defined.

but my only point was the aggregate stats that the user or app cares
about is in your
so called already present 'well-defined structure'. everything
else...ie the breakdowns are purely for
debuggability and hence falls into the other bucket which you call
"debugfs" like.

splitting the kernel default interface stats into HW and SW is going
to confuse people
on the existing api and may introduce ambiguity for future stats is
all i am saying.
