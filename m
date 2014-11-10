From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 00/10] introduce rocker switch driver with
 hardware accelerated datapath api - phase 1: bridge fdb offload
Date: Sun, 09 Nov 2014 23:03:40 -0500
Message-ID: <5460391C.3010107@mojatatu.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <5460319B.2010605@mojatatu.com> <20141110034612.GB17246@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, alexander.h.duyck@redhat.com,
	john.ronciak@intel.com, mleitner@redhat.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:63350 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752075AbaKJEDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 23:03:46 -0500
Received: by mail-ig0-f176.google.com with SMTP id l13so17235654iga.9
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 20:03:45 -0800 (PST)
In-Reply-To: <20141110034612.GB17246@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Simon,

On 11/09/14 22:46, Simon Horman wrote:
> Hi Jamal, Hi Jiri,
>
> On a somewhat related note I am also wondering what if any progress has
> been made regarding discussions of (and code for) the following:
>
> 1. Exposing flow tables to user-space
>     - I realise that this is Open vSwitch specific to some extent
>       but I am in no way implying that it should be done instead of
>       non-Open vSwitch specific work.
>     - Jiri, IIRC this was part ~v2 of your earlier offload patchset
>

I dont know what Rocker crowd is doing; however, I know
John F. has been doing some work which i have stared at
and I was hoping to join in with Ben's effort and show tc flow
offload on the realtek chip in my infinite spare time unles.
(for both Linux bridge and ports).
The priority is to merge the obvious bits first.

> 2. Describing Switch Hardware
>     - I see John Fastabend moving forwards on this in his git repository
>       https://github.com/jrfastab/flow-net-next
>
> The way that I see things is that both of the above could be exposed via
> netlink. And that the first at least could be backed by NDOs.  As such I
> see this work as complementary and perhaps applying on top of this
> patchset. If I am mistaken in this regards it would be good to know :)
>

You are correct - I will let John speak on his work, but
that is the intent.
The challenge is there are many schools of thoughts and i am hoping
it is not an arms race.

> I am of course also interested to know if the above are moving forwards.
> To be clear I am very interested in being able to use these APIs to
> perform Open vSwitch offloads and I am very happy to help.
> (Jamal: I'm also interested in non-Open vSwitch offloads :)
>

Hey, OVS should be able to use these APIs; i am just interested in 
making sure they are not just for OVS or OF. Then we are all happy;->

cheers,
jamal
