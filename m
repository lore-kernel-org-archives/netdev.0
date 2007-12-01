From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCHv7 iproute2 2/2] Interface group as new ip link option
Date: Sat, 01 Dec 2007 23:10:50 +0100
Message-ID: <4751DBEA.3050705@o2.pl>
References: <11963527094077-git-send-email-panther@balabit.hu> <11963527103201-git-send-email-panther@balabit.hu> <1196352710402-git-send-email-panther@balabit.hu> <11963527101876-git-send-email-panther@balabit.hu> <11963527103391-git-send-email-panther@balabit.hu> <11963527102332-git-send-email-panther@balabit.hu> <11963527101629-git-send-email-panther@balabit.hu> <11963527101123-git-send-email-panther@balabit.hu> <11963527101117-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:46420 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751221AbXLAWJV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 17:09:21 -0500
In-Reply-To: <11963527101117-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Laszlo Attila Toth wrote, On 11/29/2007 05:11 PM:

> Interfaces can be grouped and each group has an unique positive integer ID.
> It can be set via ip link. Symbolic names can be specified in
> /etc/iproute2/rt_ifgroup. Any value of unsigned int32 is valid.

...

> diff --git a/lib/rt_names.c b/lib/rt_names.c
> index 8d019a0..ec6638c 100644
> --- a/lib/rt_names.c
> +++ b/lib/rt_names.c
> @@ -439,10 +439,72 @@ int rtnl_dsfield_a2n(__u32 *id, char *arg)
>  		}
>  	}
>  
> -	res = strtoul(arg, &end, 16);
> +	res = strtoul(arg, &end, 0);


Won't this break any scripts?

Jarek P.
