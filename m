From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] tcp: turn ABC off
Date: Sat, 2 Sep 2006 11:22:48 +0400
Message-ID: <20060902072248.GA27419@2ka.mipt.ru>
References: <20060831151456.12a4e080@dxpl.pdx.osdl.net> <20060831.154428.35684218.davem@davemloft.net> <20060831232923.GA10036@ms2.inr.ac.ru> <20060831.165701.104033558.davem@davemloft.net> <20060901094715.GB13855@ms2.inr.ac.ru> <20060901110038.GA3651@2ka.mipt.ru> <20060901090046.69b3d583@localhost.localdomain> <20060901135515.3f900340@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, alex@sectorb.msk.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:65255 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750836AbWIBHXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2006 03:23:38 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060901135515.3f900340@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 01, 2006 at 01:55:15PM -0700, Stephen Hemminger (shemminger@osdl.org) wrote:
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 111ff39..159fa3f 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -89,7 +89,7 @@ int sysctl_tcp_frto;
>  int sysctl_tcp_nometrics_save;
>  
>  int sysctl_tcp_moderate_rcvbuf = 1;
> -int sysctl_tcp_abc = 1;
> +int sysctl_tcp_abc;

Since it is not static are you sure it will be zero?

-- 
	Evgeniy Polyakov

-- 
VGER BF report: H 8.21099e-10
