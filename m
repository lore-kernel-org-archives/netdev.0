From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 09/17] bridge: add API to notify bridge driver
 of learned FBD on offloaded device
Date: Tue, 25 Nov 2014 11:01:23 -0500
Message-ID: <5474A7D3.9060108@mojatatu.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-10-git-send-email-jiri@resnulli.us>
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
Received: from mail-ie0-f179.google.com ([209.85.223.179]:34398 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbaKYQB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:01:27 -0500
Received: by mail-ie0-f179.google.com with SMTP id rp18so767570iec.24
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 08:01:26 -0800 (PST)
In-Reply-To: <1416911328-10979-10-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 05:28, Jiri Pirko wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> When the swdev device learns a new mac/vlan on a port, it sends some async
> notification to the driver and the driver installs an FDB in the device.
> To give a holistic system view, the learned mac/vlan should be reflected
> in the bridge's FBD table, so the user, using normal iproute2 cmds, can view
> what is currently learned by the device.  This API on the bridge driver gives
> a way for the swdev driver to install an FBD entry in the bridge FBD table.
> (And remove one).
>
> This is equivalent to the device running these cmds:
>
>    bridge fdb [add|del] <mac> dev <dev> vid <vlan id> master
>
> This patch needs some extra eyeballs for review, in paricular around the
> locking and contexts.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Like it (thanks for taking the earlier feedback) but I do not see
other issue we discussed on policy attribute check that
says "I need you to sync this from offload/chip to kernel" so for now
only conditional Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
