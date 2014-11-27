From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v4 14/21] bridge: add brport flags to dflt bridge_getlink
Date: Thu, 27 Nov 2014 08:17:00 -0500
Message-ID: <5477244C.2030507@mojatatu.com>
References: <1417084826-9875-1-git-send-email-jiri@resnulli.us> <1417084826-9875-15-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
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
	bcrl@kvack.org, hemal@broadcom.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:50210 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbaK0NRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 08:17:05 -0500
Received: by mail-ie0-f170.google.com with SMTP id rd18so4580472iec.1
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 05:17:03 -0800 (PST)
In-Reply-To: <1417084826-9875-15-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/27/14 05:40, Jiri Pirko wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> To allow brport device to return current brport flags set on port.  Add
> returned flags to nested IFLA_PROTINFO netlink msg built in dflt getlink.
> With this change, netlink msg returned for bridge_getlink contains the port's
> offloaded flag settings (the port's SELF settings).

Am i missing something or we already have this stuff showing up in user
space today?

cheers,
jamal
