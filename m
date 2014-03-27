From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Thu, 27 Mar 2014 16:46:37 -0700
Message-ID: <CAGVrzca=F+jkmpUGViopZ8fXh7M3YBEr2qZAomR5yD+E04XX9Q@mail.gmail.com>
References: <53334BDA.1060608@mojatatu.com> <CAGVrzcaconDBjgSfk0=6px2+6LbrxMkmesgigSa3-9WaK-LiOw@mail.gmail.com>
 <20140327065616.GA2845@minipsycho.orion> <CAHNKnsQYLNfkrC0088g2os30NcSz9HVzkytbK_qFbNfeSWkmFw@mail.gmail.com>
 <20140327165550.GN2845@minipsycho.orion> <CAHNKnsRrb1ZoV0he0jLjJ3TBRScHcs6XRxiXrscHRJ6X3=VuGQ@mail.gmail.com>
 <CAGVrzcZ5JpTZFTMkhLOoh8GMWPDitn=gsVkPLv7rpD3fH3kavQ@mail.gmail.com>
 <53349C6C.6050506@mojatatu.com> <CAGVrzcY5rhyu3KC2PQd0X+xdBB1D2yJhhPWntLRNoOhTSfDvoQ@mail.gmail.com>
 <53349F5C.8090205@mojatatu.com> <20140327234238.GD13573@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Sergey Ryazanov <ryazanov.s.a@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>,
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
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:39159 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756835AbaC0XrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 19:47:17 -0400
Received: by mail-pb0-f45.google.com with SMTP id uo5so4174665pbc.32
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 16:47:17 -0700 (PDT)
In-Reply-To: <20140327234238.GD13573@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-03-27 16:42 GMT-07:00 Thomas Graf <tgraf@suug.ch>:
> On 03/27/14 at 05:59pm, Jamal Hadi Salim wrote:
>> On 03/27/14 17:54, Florian Fainelli wrote:
>> >2014-03-27 14:47 GMT-07:00 Jamal Hadi Salim <jhs@mojatatu.com>:
>>
>> >I think it is. There is nothing in-tree that actually uses that
>> >feature (switch chaining), but all the infrastructure is there to:
>> >
>> >- represent links between switches, which one is cascaded from which
>> >one and get a sense of their addressing within the switch tree
>> >- a function call to get that cascading table to programmed to each switch
>> >- get all relevant "uplink/downlink" switch ports to be configured appropriately
>> >
>>
>> Sounds like we have a winner on this aspect at least.
>> Is it a common setup to have such cascading though - or is this some
>> overzelous way of solving cascading switches within a LAN?
>
> If the DSA code can be refactored, even better. Any issues with
> bumping these Florian?
>
> #define DSA_MAX_SWITCHES        4
> #define DSA_MAX_PORTS           12

I don't have access to the relevant datasheets at the moment, so I
can't remember on the top of my head whether that represents a hard
limit for all the Marvell switches drivers in tree (Lennert would
surely know), but at any rate, this should certainly be made dynamic
based on what the switch driver advertises, so please go ahead bumping
those.
-- 
Florian
