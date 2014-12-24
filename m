From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 3/6] bridge/fdb: add flag/indication for FDB
 entry synced from offload device
Date: Wed, 24 Dec 2014 12:39:20 -0800
Message-ID: <20141224123920.7ceacd6e@urahara>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
	<1417683438-10935-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:57881 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbaLXUjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 15:39:41 -0500
Received: by mail-pd0-f180.google.com with SMTP id w10so10354717pde.25
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 12:39:41 -0800 (PST)
In-Reply-To: <1417683438-10935-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  4 Dec 2014 09:57:15 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> From: Scott Feldman <sfeldma@gmail.com>
> 
> Add NTF_EXT_LEARNED flag to neigh flags to indicate FDB entry learned by
> device has been learned externally to bridge FDB.  For these entries,
> add "external" annotation in bridge fdb show output:
> 
>   00:02:00:00:03:00 dev swp2 used 2/2 master br0 external
>   00:02:00:00:03:00 dev swp2 self permanent
> 
> In the example above, 00:02:00:00:03:00 is shown twice on dev swp2.  The
> first entry if from the bridge (master) and is marked as "external" by
> the offload device.  The second entry is from the brport offload device (self),
> and was learned by the device.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Does not apply to current code.
Please resubmit (with out the change to neighbour.h which is already there).
