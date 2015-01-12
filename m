From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 2/6] vxlan: Group Policy extension
Date: Mon, 12 Jan 2015 10:14:57 -0800
Message-ID: <CA+mtBx8SWiwjBfxx05omur1gDeF9QcKtjDKJQ+XdUgi_U8LWig@mail.gmail.com>
References: <cover.1420756324.git.tgraf@suug.ch>
	<7339e3bff124cecaf65cd04ea9bdc973c730ba34.1420756324.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:48480 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753765AbbALSO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 13:14:58 -0500
Received: by mail-ie0-f172.google.com with SMTP id tr6so26667061ieb.3
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 10:14:57 -0800 (PST)
In-Reply-To: <7339e3bff124cecaf65cd04ea9bdc973c730ba34.1420756324.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index f7d0d2d..9f07bf5 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -370,10 +370,18 @@ enum {
>         IFLA_VXLAN_UDP_CSUM,
>         IFLA_VXLAN_UDP_ZERO_CSUM6_TX,
>         IFLA_VXLAN_UDP_ZERO_CSUM6_RX,
> +       IFLA_VXLAN_EXTENSION,
>         __IFLA_VXLAN_MAX
>  };
>  #define IFLA_VXLAN_MAX (__IFLA_VXLAN_MAX - 1)
>
> +enum {
> +       IFLA_VXLAN_EXT_UNSPEC,
> +       IFLA_VXLAN_EXT_GBP,
> +       __IFLA_VXLAN_EXT_MAX,
> +};
> +#define IFLA_VXLAN_EXT_MAX (__IFLA_VXLAN_EXT_MAX - 1)
> +

Creating a level of indirection for extensions seems overly
complicated to me. Why not just define IFLA_VXLAN_GBP as just another
enum above?

Tom
