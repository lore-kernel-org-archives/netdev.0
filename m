From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 14/17] bridge: add new brport flag LEARNING_SYNC
Date: Tue, 25 Nov 2014 11:06:34 -0500
Message-ID: <5474A90A.4030500@mojatatu.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-15-git-send-email-jiri@resnulli.us>
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
Received: from mail-ie0-f170.google.com ([209.85.223.170]:36574 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbaKYQGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:06:38 -0500
Received: by mail-ie0-f170.google.com with SMTP id rd18so820048iec.15
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 08:06:37 -0800 (PST)
In-Reply-To: <1416911328-10979-15-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 05:28, Jiri Pirko wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> This policy flag controls syncing of learned FDB entries to bridge's FDB.  If
> on, FDB entries learned on bridge port device will be synced.  If off, device
> may still learn new FDB entries but they will not be synced with bridge's FDB.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Ah - so this is hiding over here.

If you introduced this patch first then showed in patch 9 that *it is 
checked against* for policy, then you can add my ACK for both

cheers,
jamal
