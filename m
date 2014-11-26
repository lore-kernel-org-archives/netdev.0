From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 04/17] net: introduce generic switch devices
 support
Date: Wed, 26 Nov 2014 18:32:04 -0500
Message-ID: <547662F4.3060408@mojatatu.com>
References: <5474A567.4040401@mojatatu.com> <20141125164954.GJ1971@nanopsycho.orion> <5474B795.3080204@mojatatu.com> <20141125215402.GA3912@casper.infradead.org> <54754A10.6020601@mojatatu.com> <CAE4R7bCYwWt5cem5_v8Y0jOSz5ER5_33bMRE2xkTPOqYvM6dUg@mail.gmail.com> <5475BB53.3070200@mojatatu.com> <20141126160859.GB13786@casper.infradead.org> <54760939.8050805@mojatatu.com> <20141126175944.GW1875@nanopsycho.orion> <20141126215034.GA32174@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	"jasowang@redhat.c
To: Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:55159 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749AbaKZXcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 18:32:12 -0500
Received: by mail-ig0-f173.google.com with SMTP id r2so7715460igi.0
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 15:32:10 -0800 (PST)
In-Reply-To: <20141126215034.GA32174@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/14 16:50, Thomas Graf wrote:

> You are requesting a name change for a proprietary driver after
> confirming that you can't publish the code. We don't even know what
> the piece of hardware you refer to is capable of.
>

I am not sure why there is such a misunderstanding. Here's the
sequence of events.

Jiri/Scott: We'll call this offload thing hanging off a port_ops
a "switch". It does one or more of L2, L3 and flows.
Jamal: I am not fond of that name because not everything that offloads
off a port is a switch (some mention of fitting even with dpdk)
Jiri: What do you have - an L3 "switch"?
Jamal: No, it is something that does offloading of packet processing off
a port with flows and action. Example a netronome would be a good fit 
(if you are to ignore Simon going for OVS).

And then things get out of control. This has *nothing* to do with any
driver or any code or anything speacilized.
Not every packet processing offload hanging off ports is a switch (I
dont think even the patch was claiming that although by now ive lost
track of where it started).

Yes, i cannot publish this code. You know that; Scott knows that and
Jiri knows. (and thats why i thought it passive aggressive when Scott
asked about the code when we are discussing a name change).
The reason i am even involved in all this is so we can actually
publish code and i can stop using proprietary SDK stuff.
While i cant release the current code I want to share my experiences
in trying to help make that API sane. Because i want to use it.
I have been doing this offload shit for at least 15 years on Linux.
I have something to say about it. Just throwing in some gauntlet
when it serves some convinience and treating me like some guy who
showed off the street making claims is bordering on the ridiculuos.

cheers,
jamal
