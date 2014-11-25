From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 16/17] bridge: add brport flags to dflt bridge_getlink
Date: Tue, 25 Nov 2014 11:08:50 -0500
Message-ID: <5474A992.5010305@mojatatu.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-17-git-send-email-jiri@resnulli.us>
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
	bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:35269 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbaKYQIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:08:54 -0500
Received: by mail-ie0-f181.google.com with SMTP id tp5so786670ieb.26
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 08:08:53 -0800 (PST)
In-Reply-To: <1416911328-10979-17-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 05:28, Jiri Pirko wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> To allow brport device to return current brport flags set on port.  Add
> returned flags to nested IFLA_PROTINFO netlink msg built in dflt getlink.
> With this change, netlink msg returned for bridge_getlink contains the port's
> offloaded flag settings (the port's SELF settings).
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Not sure i followed this. VEPA etc are offload modes, no?
I like the harvesting from netlink->internal format but
not sure i followed the rest: VEPA etc are offload modes, no?

cheers,
jamal
