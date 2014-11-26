From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 17/17] rocker: add ndo_bridge_setlnk/getlink
 support for learning policy
Date: Wed, 26 Nov 2014 12:42:50 +0100
Message-ID: <20141126114250.GN1875@nanopsycho.orion>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-18-git-send-email-jiri@resnulli.us>
 <20141126110709.GC4321@casper.infradead.org>
 <20141126112718.GK1875@nanopsycho.orion>
 <20141126113024.GA8410@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
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
	bcrl@kvack.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:55590 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbaKZLmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 06:42:52 -0500
Received: by mail-wg0-f49.google.com with SMTP id x12so3446718wgg.22
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 03:42:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141126113024.GA8410@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Nov 26, 2014 at 12:30:24PM CET, tgraf@suug.ch wrote:
>On 11/26/14 at 12:27pm, Jiri Pirko wrote:
>> Wed, Nov 26, 2014 at 12:07:09PM CET, tgraf@suug.ch wrote:
>> >The Netlink message is completely unverified at this point. All
>> >rtnl_bridge_setlink() does is verify that msgsize >= ifinfomsg.
>> >All of the drivers but br_setlink() need fixing in this regard.
>> 
>> I believe that we should fix this for all drivers in a follow-up patch.
>
>I'm working on this. Will send fixes later today.


Feel free to fix rocker as well. I'll take your patch into my queue.
