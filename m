From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 01/10] net: rename netdev_phys_port_id to
 more generic name
Date: Mon, 10 Nov 2014 14:16:22 +0100
Message-ID: <20141110131622.GC4256@nanopsycho.orion>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
 <1415530280-9190-2-git-send-email-jiri@resnulli.us>
 <54603270.509@mojatatu.com>
 <20141110074344.GB1850@nanopsycho.orion>
 <5460ACC0.3020805@mojatatu.com>
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
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38174 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbaKJNQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 08:16:28 -0500
Received: by mail-wi0-f181.google.com with SMTP id n3so10362702wiv.8
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 05:16:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5460ACC0.3020805@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 10, 2014 at 01:17:04PM CET, jhs@mojatatu.com wrote:
>On 11/10/14 02:43, Jiri Pirko wrote:
>>Mon, Nov 10, 2014 at 04:35:12AM CET, jhs@mojatatu.com wrote:
>
>>I don't see a reason why this would break kabi:
>>
>>-#define MAX_PHYS_PORT_ID_LEN 32
>>+#define MAX_PHYS_ITEM_ID_LEN 32
>>
>
>refer to my response to Dave. Just define MAX_PHYS_PORT_ID_LEN to
>MAX_PHYS_ITEM_ID_LEN so people dont have to change their code
>because a name change.

Jamal, please look at the patch & code. MAX_PHYS_PORT_ID_LEN is in
include/linux/netdevice.h which is not part of user exported api.

>
>cheers,
>jamal
