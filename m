From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Wed, 26 Mar 2014 18:53:51 -0400
Message-ID: <53335A7F.8010801@mojatatu.com>
References: <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org> <CAGVrzcbRggJV+5+EuZnXVoU+qdK9ugPRL+J-mp-UraGuo19jnQ@mail.gmail.com> <5332677F.2090404@cumulusnetworks.com> <5332B1FE.7080102@mojatatu.com> <53330639.8050403@cumulusnetworks.com> <20140326165934.GH2869@minipsycho.orion> <CAGVrzcbBq2=DG198NnpSWu52+uuundqQ-6QiiuzHF5X_j8fcZw@mail.gmail.com> <20140326173536.GJ2869@minipsycho.orion> <CAGVrzca84nbsyG3ETvn4nkgpMtYTh_dFDbzCywSdQ9uJjLVOUg@mail.gmail.com> <20140326181436.GL2869@minipsycho.orion> <53334BDA.1060608@mojatatu.com> <CAGVrzcaconDBjgSfk0=6px2+6LbrxMkmesgigSa3-9WaK-LiOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Felix Fietkau <nbd@openwrt.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:60389 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755876AbaCZWxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 18:53:54 -0400
Received: by mail-ie0-f173.google.com with SMTP id rl12so2430353iec.4
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 15:53:54 -0700 (PDT)
In-Reply-To: <CAGVrzcaconDBjgSfk0=6px2+6LbrxMkmesgigSa3-9WaK-LiOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/14 18:22, Florian Fainelli wrote:
> 2014-03-26 14:51 GMT-07:00 Jamal Hadi Salim <jhs@mojatatu.com>:

>
> eth0 corresponds to a CPU Ethernet MAC facing e.g: sw1p3 switch port.
> It is "regular" Ethernet driver connected to the switch without
> switch-specific logic. The goal is twofold:
>
> - allow any regular Ethernet driver to be connected to an external
> switch via e.g: MDIO/MDC or other without specific switch knowledge
> - represents accurately how the hardware is designed/connected
>

Gah. Sorry - I missed the MII interface.
In such a case as shown here then, how do you control sw1p0-3?

> but maybe, we can simplify and have e.g: sw1p3 and eth0 be the same interface...

It sounds to me the CPU side is only a driver for sw1p3.

>>
>> Note: even the high end chips tend to have the concept of a "cpu port"
>> but my experience is to hide that as part of the switch driver.

Note: the high end devices "cpu ports" are accessible typically
via PCIE interfaces for control and some DMA for data activity.

cheers,
jamal
