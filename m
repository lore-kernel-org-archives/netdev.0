From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next v2 03/10] rtnl: expose physical switch id for
 particular device
Date: Mon, 10 Nov 2014 14:01:09 -0800
Message-ID: <546135A5.1050700@gmail.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <1415530280-9190-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvac
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:62498 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbaKJWBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 17:01:47 -0500
Received: by mail-ob0-f172.google.com with SMTP id wp4so6532532obc.3
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 14:01:47 -0800 (PST)
In-Reply-To: <1415530280-9190-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2014 02:51 AM, Jiri Pirko wrote:
> The netdevice represents a port in a switch, it will expose
> IFLA_PHYS_SWITCH_ID value via rtnl. Two netdevices with the same value
> belong to one physical switch.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---

Yep, I need something like this for my management app to
learn how the switch is laid out. This becomes more relevant
if I have switch silicon mixed with NICs that are not connected
to the switch object in the same platform.

Acked-by: John Fastabend <john.r.fastabend@intel.com>


-- 
John Fastabend         Intel Corporation
