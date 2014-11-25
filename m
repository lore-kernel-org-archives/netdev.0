From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 07/17] rocker: introduce rocker switch driver
Date: Tue, 25 Nov 2014 17:57:45 +0100
Message-ID: <20141125165745.GM1971@nanopsycho.orion>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-8-git-send-email-jiri@resnulli.us>
 <5474A705.5070007@mojatatu.com>
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
Received: from mail-wg0-f52.google.com ([74.125.82.52]:45419 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbaKYQ5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:57:48 -0500
Received: by mail-wg0-f52.google.com with SMTP id a1so1423314wgh.11
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 08:57:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5474A705.5070007@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 25, 2014 at 04:57:57PM CET, jhs@mojatatu.com wrote:
>On 11/25/14 05:28, Jiri Pirko wrote:
>>This patch introduces the first driver to benefit from the switchdev
>>infrastructure and to implement newly introduced switch ndos. This is a
>>driver for emulated switch chip implemented in qemu:
>>https://github.com/sfeldma/qemu-rocker/
>>
>>This patch is a result of joint work with Scott Feldman.
>>
>>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>Reviewed-by: Thomas Graf <tgraf@suug.ch>
>>Reviewed-by: John Fastabend <john.r.fastabend@intel.com>
>
>Users should be a different patch set for easier review.
>I think you should separate rocker to be another patch series.

Hmm. When we introduce a new ops/callbacks, we need to use it in the
same patchset. That is the rule if I'm not mistaken. That is why I send
this together. I do not see any problems in that given the fact that
rocker is new driver so it cannot indroduce a regression.
I would like to keep pushing this as a single patchset.

>
>cheers,
>jamal
>
