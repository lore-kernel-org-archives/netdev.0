From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 01/10] net: rename netdev_phys_port_id to
 more generic name
Date: Mon, 10 Nov 2014 07:17:04 -0500
Message-ID: <5460ACC0.3020805@mojatatu.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <1415530280-9190-2-git-send-email-jiri@resnulli.us> <54603270.509@mojatatu.com> <20141110074344.GB1850@nanopsycho.orion>
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
Received: from mail-ig0-f178.google.com ([209.85.213.178]:43383 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbaKJMRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 07:17:09 -0500
Received: by mail-ig0-f178.google.com with SMTP id a13so8952221igq.11
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 04:17:08 -0800 (PST)
In-Reply-To: <20141110074344.GB1850@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/14 02:43, Jiri Pirko wrote:
> Mon, Nov 10, 2014 at 04:35:12AM CET, jhs@mojatatu.com wrote:

> I don't see a reason why this would break kabi:
>
> -#define MAX_PHYS_PORT_ID_LEN 32
> +#define MAX_PHYS_ITEM_ID_LEN 32
>

refer to my response to Dave. Just define MAX_PHYS_PORT_ID_LEN to
MAX_PHYS_ITEM_ID_LEN so people dont have to change their code
because a name change.

cheers,
jamal
