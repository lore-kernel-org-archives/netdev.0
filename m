From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 07/17] rocker: introduce rocker switch driver
Date: Tue, 25 Nov 2014 18:15:14 +0100
Message-ID: <20141125171514.GN1971@nanopsycho.orion>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-8-git-send-email-jiri@resnulli.us>
 <5474A705.5070007@mojatatu.com>
 <20141125.121019.465267851168750694.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jhs@mojatatu.com, netdev@vger.kernel.org, nhorman@tuxdriver.com,
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
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:52520 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbaKYRPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 12:15:17 -0500
Received: by mail-wi0-f181.google.com with SMTP id r20so2215888wiv.2
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 09:15:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141125.121019.465267851168750694.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 25, 2014 at 06:10:19PM CET, davem@davemloft.net wrote:
>From: Jamal Hadi Salim <jhs@mojatatu.com>
>Date: Tue, 25 Nov 2014 10:57:57 -0500
>
>> On 11/25/14 05:28, Jiri Pirko wrote:
>>> This patch introduces the first driver to benefit from the switchdev
>>> infrastructure and to implement newly introduced switch ndos. This is
>>> a
>>> driver for emulated switch chip implemented in qemu:
>>> https://github.com/sfeldma/qemu-rocker/
>>>
>>> This patch is a result of joint work with Scott Feldman.
>>>
>>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>> Reviewed-by: Thomas Graf <tgraf@suug.ch>
>>> Reviewed-by: John Fastabend <john.r.fastabend@intel.com>
>> 
>> Users should be a different patch set for easier review.
>> I think you should separate rocker to be another patch series.
>
>I want to see how the new infrastructure is used in the same patch
>series as the changes that add that infrastructure.

Yep. For easier review, I will move the rocker patches to the tail and
leave the other ones on head.
