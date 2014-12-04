From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch iproute2 0/6] iproute2: add changes for switchdev
Date: Thu, 04 Dec 2014 08:16:38 -0500
Message-ID: <54805EB6.2010901@mojatatu.com>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
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
Received: from mail-ie0-f178.google.com ([209.85.223.178]:65407 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbaLDNQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 08:16:43 -0500
Received: by mail-ie0-f178.google.com with SMTP id tp5so15387295ieb.23
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 05:16:42 -0800 (PST)
In-Reply-To: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


General comment:
iproute2 patches need to be addressed to the maintainer
stephen@networkplumber.org
And are we mainstream enough now we can drop the 1000 people on the
To: list? I doubt most of these people are even following the discussion 
(I planted an easter egg for Aviad and didnt see him
reacting) ;->

cheers,
jamal

On 12/04/14 03:57, Jiri Pirko wrote:
> Jiri Pirko (1):
>    iproute2: ipa: show switch id
>
> Scott Feldman (5):
>    bridge/fdb: fix statistics output spacing
>    bridge/fdb: add flag/indication for FDB entry synced from offload
>      device
>    bridge/link: add new offload hwmode swdev
>    link: add missing IFLA_BRPORT_PROXYARP
>    bridge/link: add learning_sync policy flag
>
>   bridge/fdb.c              |  4 +++-
>   bridge/link.c             | 17 +++++++++++++++--
>   include/linux/if_bridge.h |  1 +
>   include/linux/if_link.h   |  3 +++
>   include/linux/neighbour.h |  1 +
>   ip/ipaddress.c            |  8 ++++++++
>   man/man8/bridge.8         | 19 ++++++++++++++-----
>   7 files changed, 45 insertions(+), 8 deletions(-)
>
