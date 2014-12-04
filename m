From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch iproute2 0/6] iproute2: add changes for switchdev
Date: Thu, 04 Dec 2014 06:26:50 -0800
Message-ID: <54806F2A.2050109@cumulusnetworks.com>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, linville@tuxdriver.com, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.horman@netronome.com, alexander.h.duyck@redhat.com,
	john.ronciak@intel.com, mleitner@redhat.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack.org, hemal@broadcom.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:38173 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932172AbaLDO1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 09:27:15 -0500
In-Reply-To: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/4/14, 12:57 AM, Jiri Pirko wrote:
> Jiri Pirko (1):
>    iproute2: ipa: show switch id
>
> Scott Feldman (5):
>    bridge/fdb: fix statistics output spacing
>    bridge/fdb: add flag/indication for FDB entry synced from offload
>      device
>    bridge/link: add new offload hwmode swdev
Ack to most patches but nack on this one. The todo list still has a note 
to revist the flag to indicate switchdev offloads.
Exposing this to userspace does not help that.

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
