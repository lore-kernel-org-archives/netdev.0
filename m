From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: Problem with __check_and_rekey
Date: Tue, 12 Aug 2003 23:09:29 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812.230929.57895537.yoshfuji@linux-ipv6.org>
References: <20030812132050.GA27178@mochrul.balabit>
	<20030812.225527.35784879.yoshfuji@linux-ipv6.org>
	<20030812065347.331e9066.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sasa@balabit.hu, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030812065347.331e9066.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030812065347.331e9066.davem@redhat.com> (at Tue, 12 Aug 2003 06:53:46 -0700), "David S. Miller" <davem@redhat.com> says:

> It doesn't matter, a proper fix was put into drivers/char/random.c
> already.
:
> -	spin_lock(&ip_lock);
> +	spin_lock_bh(&ip_lock);
:
> -	spin_unlock(&ip_lock);
> +	spin_unlock_bh(&ip_lock);
>  	return keyptr;

Ah, exactly.  Thanks for information.

--yoshfuji
