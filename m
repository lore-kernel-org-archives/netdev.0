From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 04/17] net: introduce generic switch devices
 support
Date: Tue, 25 Nov 2014 17:49:54 +0100
Message-ID: <20141125164954.GJ1971@nanopsycho.orion>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-5-git-send-email-jiri@resnulli.us>
 <5474A567.4040401@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:39915 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbaKYQt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:49:57 -0500
Received: by mail-wi0-f177.google.com with SMTP id l15so2124653wiw.4
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 08:49:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5474A567.4040401@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 25, 2014 at 04:51:03PM CET, jhs@mojatatu.com wrote:
>On 11/25/14 05:28, Jiri Pirko wrote:
>>The goal of this is to provide a possibility to support various switch
>>chips. Drivers should implement relevant ndos to do so. Now there is
>>only one ndo defined:
>>- for getting physical switch id is in place.
>>
>
>I am not sure switch id is the right term. I have a network processor
>that *does not* do switching. I am not sure if "chip" or "ASIC" or

What does it do? "L3 switching"?

>"offload_id" would be the right term. switch doesnt sound right.

When we talk about this area, we use word "switch". I know it is not
accurate, but in my opinion it is the closest we can get. "chip" and
"ASIC" are too generic I believe. I would not use "offload" cause it wan
be easily mistaken with NIC offloads + it is alsno not accurate.



>
>cheers,
>jamal
>
