From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v4 09/21] bridge: call netdev_sw_port_stp_update
 when bridge port STP status changes
Date: Thu, 27 Nov 2014 14:43:41 +0100
Message-ID: <20141127134341.GC1877@nanopsycho.orion>
References: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
 <1417084826-9875-10-git-send-email-jiri@resnulli.us>
 <547723AC.1070907@mojatatu.com>
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
	bcrl@kvack.org, hemal@broad
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:33197 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886AbaK0Nnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 08:43:45 -0500
Received: by mail-wg0-f54.google.com with SMTP id l2so6531293wgh.27
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 05:43:44 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <547723AC.1070907@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Nov 27, 2014 at 02:14:20PM CET, jhs@mojatatu.com wrote:
>On 11/27/14 05:40, Jiri Pirko wrote:
>>From: Scott Feldman <sfeldma@gmail.com>
>>
>>To notify switch driver of change in STP state of bridge port, add new
>>.ndo op and provide switchdev wrapper func to call ndo op. Use it in bridge
>>code then.
>>
>
>As it stands right now we are going to pollute the ndo ops and grow
>it fatter like the skb (its probably as fat).
>If i am not mistaken ethtool has some scheme it uses to pass opaque
>objects to different functions. Having a generic
>set/get_netdev_offload_attr() would be the right thing to do.
>An {id, *value} or {id, len, *value} or a void * would do.
>So not objecting - but not ACKing either.

Yeah, this will be changed in future when more and more info will need
to be passed to offloads.

>
>cheers,
>jamal
>
