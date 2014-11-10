From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 06/10] bridge: introduce fdb offloading via
 switchdev
Date: Mon, 10 Nov 2014 14:13:54 -0500
Message-ID: <54610E72.9040605@mojatatu.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <1415530280-9190-7-git-send-email-jiri@resnulli.us> <54603564.3070606@mojatatu.com> <20141110081552.GD1850@nanopsycho.orion> <5460B3E5.7020502@mojatatu.com> <20141110134715.GD4256@nanopsycho.orion>
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
Received: from mail-ig0-f177.google.com ([209.85.213.177]:60789 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbaKJTN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 14:13:57 -0500
Received: by mail-ig0-f177.google.com with SMTP id hl2so9694091igb.16
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 11:13:57 -0800 (PST)
In-Reply-To: <20141110134715.GD4256@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/14 08:47, Jiri Pirko wrote:
> Mon, Nov 10, 2014 at 01:47:33PM CET, jhs@mojatatu.com wrote:

>
> Because now, If you would like to pass one of NDA_DST, NDA_LLADDR,
> NDA_CACHEINFO, NDA_PROBES, NDA_VLAN, NDA_PORT, NDA_VNI, NDA_IFINDEX,
> NDA_MASTER values via ndo_fdb_add/del to the driver, you have to
> construct "struct nlattr *tb[]". Preprocessing this tb into struct might
> be suitable for some use-case, for some it may not.
>

Ok, I see what you mean now. yes, netlink attributes are passed around.

>
> What I try to say is that the naming ndo_fdb_add/del is not accurate
> because it is now used for far more than fdb (addr, vlan). See vxlan
> code for example.
>

In vxlan semantics that is an "fdb".
In any case, I am indifferent to be honest - netlink attributes in
this case seem to be easier. i.e For the driver:
Ignore what you dont want and suck in what you need (whether vxlan
or vlan or nvgre etc).

cheers,
jamal
