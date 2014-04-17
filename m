From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [patch iproute2 RFC v3 4/5] iproute2: add support for dummyswport
Date: Thu, 17 Apr 2014 15:19:51 +0200
Message-ID: <534FD4F7.5060402@6wind.com>
References: <1397736876-11771-1-git-send-email-jiri@resnulli.us> <1397737053-11892-1-git-send-email-jiri@resnulli.us> <1397737053-11892-5-git-send-email-jiri@resnulli.us>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:36405 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161240AbaDQNTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2014 09:19:55 -0400
Received: by mail-wi0-f170.google.com with SMTP id bs8so2723728wib.1
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2014 06:19:54 -0700 (PDT)
In-Reply-To: <1397737053-11892-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/04/2014 14:17, Jiri Pirko a =C3=A9crit :
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   include/linux/if_link.h |  9 ++++++++
>   ip/Makefile             |  3 ++-
>   ip/iplink_dummyswport.c | 56 ++++++++++++++++++++++++++++++++++++++=
+++++++++++
>   3 files changed, 67 insertions(+), 1 deletion(-)
>   create mode 100644 ip/iplink_dummyswport.c

Don't forget to update iplink_usage() in ip/iplink.c, with the new type=
=2E
