From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Bluetooth BUG() in set_sk_owner().
Date: 15 Sep 2003 11:57:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063619827.28891.507.camel@pegasus>
References: <1063184337.32473.529.camel@hades.cambridge.redhat.com>
	<20030911182223.2e9b7118.davem@redhat.com>
	<1063616050.21195.67.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
   shemminger@osdl.org, Max Krasnyansky <maxk@qualcomm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1063616050.21195.67.camel@hades.cambridge.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

> Needs this too...
> 
> ===== net/bluetooth/bnep/sock.c 1.11 vs edited =====
> --- 1.11/net/bluetooth/bnep/sock.c	Thu Jun  5 01:57:08 2003
> +++ edited/net/bluetooth/bnep/sock.c	Fri Sep 12 09:16:17 2003
> @@ -186,7 +189,8 @@
>  
>  static struct net_proto_family bnep_sock_family_ops = {
>  	.family = PF_BLUETOOTH,
> -	.create = bnep_sock_create
> +	.create = bnep_sock_create,
> +	.owner = THIS_MODULE
>  };
>  
>  int __init bnep_sock_init(void)

it is only cosmetic, but put the .owner above the .create.

Regards

Marcel
