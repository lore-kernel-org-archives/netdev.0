From: Jeff Garzik <jgarzik@pobox.com>
Subject: hamradio/baycom and "make allyesconfig"
Date: Sat, 27 Sep 2003 22:21:00 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F76458C.7030600@pobox.com>
References: <20030926164821.1e83dce9.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030926164821.1e83dce9.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Can you fix this up, in 2.6.0-test6?


>   CC      drivers/net/hamradio/bpqether.o
>   CC      drivers/net/hamradio/baycom_ser_fdx.o
> drivers/net/hamradio/baycom_ser_fdx.c: In function `init_baycomserfdx':
> drivers/net/hamradio/baycom_ser_fdx.c:641: warning: implicit declaration of function `hdlcdrv_register'
> drivers/net/hamradio/baycom_ser_fdx.c:643: warning: assignment makes pointer from integer without a cast
> drivers/net/hamradio/baycom_ser_fdx.c: In function `cleanup_baycomserfdx':
> drivers/net/hamradio/baycom_ser_fdx.c:667: warning: implicit declaration of function `hdlcdrv_unregister'
>   CC      drivers/net/hamradio/hdlcdrv.o
>   CC      drivers/net/hamradio/baycom_ser_hdx.o
> drivers/net/hamradio/baycom_ser_hdx.c: In function `init_baycomserhdx':
> drivers/net/hamradio/baycom_ser_hdx.c:678: warning: implicit declaration of function `hdlcdrv_register'
> drivers/net/hamradio/baycom_ser_hdx.c:680: warning: assignment makes pointer from integer without a cast
> drivers/net/hamradio/baycom_ser_hdx.c: In function `cleanup_baycomserhdx':
> drivers/net/hamradio/baycom_ser_hdx.c:704: warning: implicit declaration of function `hdlcdrv_unregister'
>   CC      drivers/net/hamradio/baycom_par.o
> drivers/net/hamradio/baycom_par.c: In function `init_baycompar':
> drivers/net/hamradio/baycom_par.c:518: warning: implicit declaration of function `hdlcdrv_register'
> drivers/net/hamradio/baycom_par.c:520: warning: assignment makes pointer from integer without a cast
> drivers/net/hamradio/baycom_par.c: In function `cleanup_baycompar':
> drivers/net/hamradio/baycom_par.c:544: warning: implicit declaration of function `hdlcdrv_unregister'
