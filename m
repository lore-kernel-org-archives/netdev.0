From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [net-next PATCH v3 3/3] net: TCP thin dupack
Date: Fri, 12 Feb 2010 18:13:13 -0800
Message-ID: <m16361ubly.fsf@fess.ebiederm.org>
References: <4B73F31F.9000204@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Ilpo =?utf-8?Q?J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>,
	william.allen.simpson@gmail.com, damian@tvk.rwth-aachen.de
To: Andreas Petlund <apetlund@simula.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:59181 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024Ab0BMCNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 21:13:23 -0500
In-Reply-To: <4B73F31F.9000204@simula.no> (Andreas Petlund's message of "Thu\, 11 Feb 2010 13\:07\:59 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andreas Petlund <apetlund@simula.no> writes:

> Major changes:
>       -Possible to disable mechanisms by socket option
>       -Socket option value boundary check
>
>
> Signed-off-by: Andreas Petlund <apetlund@simula.no>
> ---
>  include/linux/sysctl.h     |    1 +
>  include/linux/tcp.h        |    4 +++-
>  include/net/tcp.h          |    1 +
>  net/ipv4/sysctl_net_ipv4.c |    7 +++++++
>  net/ipv4/tcp.c             |    7 +++++++
>  net/ipv4/tcp_input.c       |   11 +++++++++++
>  6 files changed, 30 insertions(+), 1 deletions(-)
>
> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> index d840d75..ded3f20 100644
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -426,6 +426,7 @@ enum
>  	NET_TCP_MAX_SSTHRESH=124,
>  	NET_TCP_FRTO_RESPONSE=125,
>  	NET_TCP_FORCE_THIN_LINEAR_TIMEOUTS=126,
> +	NET_TCP_FORCE_THIN_LINEAR_DUPACK=127,

There is no need to allocate a binary sysctl here.

Eric
