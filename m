From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Fri, 19 Sep 2014 17:49:46 +0200
Message-ID: <20140919154946.GH1980@nanopsycho.orion>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us>
 <1411134590-4586-9-git-send-email-jiri@resnulli.us>
 <541C4AFC.8060500@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.horman@netronome.com, alexander.h.duyck@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:53747 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756232AbaISPts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 11:49:48 -0400
Received: by mail-wg0-f42.google.com with SMTP id y10so532916wgg.1
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 08:49:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <541C4AFC.8060500@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 19, 2014 at 05:25:48PM CEST, jhs@mojatatu.com wrote:
>On 09/19/14 09:49, Jiri Pirko wrote:
>>This patch exposes switchdev API using generic Netlink.
>>Example userspace utility is here:
>>https://github.com/jpirko/switchdev
>>
>
>Is this just a temporary test tool? Otherwise i dont see reason
>for its existence (or the API that it feeds on).

Please read the conversation I had with Pravin and Jesse in v1 thread.
Long story short they like to have the api separated from ovs datapath
so ovs daemon can use it to directly communicate with driver. Also John
Fastabend requested a way to work with driver flows without using ovs ->
that was the original reason I created switchdev genl api.

Regarding the "sw" tool, yes it is for testing purposes now. ovs daemon
will use directly switchdev genl api.

I hope I cleared this out.
