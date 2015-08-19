From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH v2 net-next 13/13] ipv6: route: per route IP tunnel metadata
 via lightweight tunnel
Date: Wed, 19 Aug 2015 19:17:21 +0900
Message-ID: <55D457B1.2080105@miraclelinux.com>
References: <cover.1439978875.git.jbenc@redhat.com> <0694438feae2730b0bd3354b5e977bc9d6a5a192.1439978875.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, Thomas Graf <tgraf@suug.ch>
To: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34935 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681AbbHSKRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 06:17:25 -0400
Received: by pacgr6 with SMTP id gr6so124009pac.2
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 03:17:24 -0700 (PDT)
In-Reply-To: <0694438feae2730b0bd3354b5e977bc9d6a5a192.1439978875.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Benc wrote:
> Allow specification of per route IP tunnel instructions also for IPv6.
> This complements commit 3093fbe7ff4b ("route: Per route IP tunnel metadata
> via lightweight tunnel").
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  include/uapi/linux/lwtunnel.h |  16 +++++++
>  net/ipv4/ip_tunnel_core.c     | 102 ++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 118 insertions(+)
> 
> diff --git a/include/uapi/linux/lwtunnel.h b/include/uapi/linux/lwtunnel.h
> index aa84ca396bcb..32a149571417 100644
> --- a/include/uapi/linux/lwtunnel.h
> +++ b/include/uapi/linux/lwtunnel.h
> @@ -7,6 +7,7 @@ enum lwtunnel_encap_types {
>  	LWTUNNEL_ENCAP_NONE,
>  	LWTUNNEL_ENCAP_MPLS,
>  	LWTUNNEL_ENCAP_IP,
> +	LWTUNNEL_ENCAP_IP6,
>  	LWTUNNEL_ENCAP_ILA,
>  	__LWTUNNEL_ENCAP_MAX,
>  };

Please do not add new one in the middle of enums.

--yoshfuji
