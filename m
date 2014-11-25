From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v3 07/17] rocker: introduce rocker switch
 driver
Date: Tue, 25 Nov 2014 12:10:19 -0500 (EST)
Message-ID: <20141125.121019.465267851168750694.davem@davemloft.net>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
	<1416911328-10979-8-git-send-email-jiri@resnulli.us>
	<5474A705.5070007@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, nhorman@tuxdriver.com,
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
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35516 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345AbaKYRK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 12:10:27 -0500
In-Reply-To: <5474A705.5070007@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Tue, 25 Nov 2014 10:57:57 -0500

> On 11/25/14 05:28, Jiri Pirko wrote:
>> This patch introduces the first driver to benefit from the switchdev
>> infrastructure and to implement newly introduced switch ndos. This is
>> a
>> driver for emulated switch chip implemented in qemu:
>> https://github.com/sfeldma/qemu-rocker/
>>
>> This patch is a result of joint work with Scott Feldman.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> Reviewed-by: Thomas Graf <tgraf@suug.ch>
>> Reviewed-by: John Fastabend <john.r.fastabend@intel.com>
> 
> Users should be a different patch set for easier review.
> I think you should separate rocker to be another patch series.

I want to see how the new infrastructure is used in the same patch
series as the changes that add that infrastructure.
