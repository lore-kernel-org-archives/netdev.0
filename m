From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9] AF_UNIX: create, join and leave multicast groups
 with setsockopt
Date: Mon, 22 Nov 2010 11:00:15 -0800 (PST)
Message-ID: <20101122.110015.183067365.davem@davemloft.net>
References: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
	<1290450982-17480-3-git-send-email-alban.crequy@collabora.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com, gorcunov@openvz.org,
	adobriyan@gmail.com, lennart@poettering.net, kay.sievers@vrfy.org,
	ian.molton@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: alban.crequy@collabora.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290450982-17480-3-git-send-email-alban.crequy@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alban Crequy <alban.crequy@collabora.co.uk>
Date: Mon, 22 Nov 2010 18:36:16 +0000

> +	other = unix_find_other(sock_net(sock->sk), &mreq->address, namelen,
> +				sock->type, hash, &err);
> +	if (other)
> +		return -EADDRINUSE;

Leaks 'other'.
