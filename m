From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] MODULE_ALIAS_PROTO for PPPoE
Date: Mon, 15 Dec 2003 11:43:48 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031215060838.E7F7C2C284@lists.samba.org>
References: <20031210102256.27d2ff51.shemminger@osdl.org>
Cc: "David S. Miller" <davem@redhat.com>,
        Rusty Russell <rusty@rustcorp.com.au>,
        Michal Ostrowski <mostrows@styk.uwaterloo.ca.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Cc: netdev@oss.sgi.com
In-reply-to: Your message of "Wed, 10 Dec 2003 10:22:56 -0800."
             <20031210102256.27d2ff51.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20031210102256.27d2ff51.shemminger@osdl.org> you write:
> Rusty added module aliases for most protocol families but missed this one.

Thanks.  I've got a few aliases accumulated.  I'll push this to Linus/Akpm
and see if they bite.

Thanks.
Rusty

> diff -Nru a/drivers/net/pppoe.c b/drivers/net/pppoe.c
> --- a/drivers/net/pppoe.c	Wed Dec 10 10:20:36 2003
> +++ b/drivers/net/pppoe.c	Wed Dec 10 10:20:36 2003
> @@ -1151,3 +1151,4 @@
>  MODULE_AUTHOR("Michal Ostrowski <mostrows@speakeasy.net>");
>  MODULE_DESCRIPTION("PPP over Ethernet driver");
>  MODULE_LICENSE("GPL");
> +MODULE_ALIAS_NETPROTO(PF_PPPOX);

--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
