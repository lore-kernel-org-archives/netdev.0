From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 0/4] net: add rx_unhandled stat counter
Date: Wed, 27 Jan 2016 13:09:47 -0800
Message-ID: <1453928987.20722.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
	 <1453926098-40181-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453926098-40181-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-01-27 at 15:21 -0500, Jarod Wilson wrote:

> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 289c231..7973ab5 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -180,6 +180,7 @@ struct net_device_stats {
>  	unsigned long	tx_window_errors;
>  	unsigned long	rx_compressed;
>  	unsigned long	tx_compressed;
> +	unsigned long	rx_unhandled;
>  };
>  

This structure is deprecated, please do not add new fields in it,
as it will increase netlink answers for no good reason.

rtnl_link_stats64 is what really matters these days.
