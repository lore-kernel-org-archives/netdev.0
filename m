From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 04/17] net: introduce generic switch devices
 support
Date: Tue, 25 Nov 2014 12:08:37 -0500
Message-ID: <5474B795.3080204@mojatatu.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-5-git-send-email-jiri@resnulli.us> <5474A567.4040401@mojatatu.com> <20141125164954.GJ1971@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:59811 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbaKYRIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 12:08:41 -0500
Received: by mail-ie0-f172.google.com with SMTP id tr6so950568ieb.17
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 09:08:41 -0800 (PST)
In-Reply-To: <20141125164954.GJ1971@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 11:49, Jiri Pirko wrote:

>
> What does it do? "L3 switching"?
>

Absolutely not - that is too easy;-> Why not just a mellanox
chip for that? (Testing if Aviad is awake). But flows and associated
constructs apply.


>> "offload_id" would be the right term. switch doesnt sound right.
>
> When we talk about this area, we use word "switch". I know it is not
> accurate, but in my opinion it is the closest we can get. "chip" and
> "ASIC" are too generic I believe. I would not use "offload" cause it wan
> be easily mistaken with NIC offloads + it is alsno not accurate.

I think this interface is usable for example to offload to user space
ala DPDK and friends just as it would be for ASICs or standard NIC
offload (which we already have with fdb offload).
I dont know what a good name is - but switch looks incorrect.

cheers,
jamal
