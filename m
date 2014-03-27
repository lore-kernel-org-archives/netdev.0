From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Thu, 27 Mar 2014 11:50:02 +0100
Message-ID: <20140327105002.GH2845@minipsycho.orion>
References: <53330639.8050403@cumulusnetworks.com>
 <20140326165934.GH2869@minipsycho.orion>
 <CAGVrzcbBq2=DG198NnpSWu52+uuundqQ-6QiiuzHF5X_j8fcZw@mail.gmail.com>
 <20140326173536.GJ2869@minipsycho.orion>
 <CAGVrzca84nbsyG3ETvn4nkgpMtYTh_dFDbzCywSdQ9uJjLVOUg@mail.gmail.com>
 <20140326181436.GL2869@minipsycho.orion>
 <53334BDA.1060608@mojatatu.com>
 <CAGVrzcaconDBjgSfk0=6px2+6LbrxMkmesgigSa3-9WaK-LiOw@mail.gmail.com>
 <20140327065616.GA2845@minipsycho.orion>
 <5333FFFF.1050005@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
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
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:34072 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755285AbaC0KuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 06:50:06 -0400
Received: by mail-ee0-f48.google.com with SMTP id b57so2665480eek.21
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 03:50:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5333FFFF.1050005@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 27, 2014 at 11:39:59AM CET, jhs@mojatatu.com wrote:
>On 03/27/14 02:56, Jiri Pirko wrote:
>>Wed, Mar 26, 2014 at 11:22:51PM CET, f.fainelli@gmail.com wrote:
>
>>
>>I believe that hawing both sw1p3 and eth0 is the correct way of
>>modelling this. sw1p3 is instance if switch chip driver representing the
>>actual port of a switch. eth0 is an instance of some other ordinary NIC
>>driver (8139too is my favorite :))
>>
>>This model allows to draw the exact picture.
>>Also, when you add the described possibility to use iplink to build
>>vlans, bridges whatever on the switch ports, it makes perfect sense to
>>have this model.
>>
>>Merging sw1p3 and eth0 would cause a loose of information and confusion.
>
>I think that if eth0 and sw1p3 have different control interfaces i
>agree.
>
>Jiri, sorry - didnt respond to your other email on your patch. My
>comment was on newlink() interface - i was wondering about why it was
>there i.e as in allowing user space to create switch ports.

In my patchset, this is only for dummyswitch. The dummy switch driver
implementation. I provides a possibility for user to create these using
iplink.

>
>cheers,
>jamal
