From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch 1/9] arcnet fixes
Date: Thu, 28 Oct 2004 16:41:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028164111.5ffaca70.davem@redhat.com>
References: <200410280721.i9S7Lb907978@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, simlo@phys.au.dk
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <200410280721.i9S7Lb907978@mail.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 28 Oct 2004 00:19:38 -0700
akpm@osdl.org wrote:

I don't know what to do with this kind of thing.
Jeff, what do you think?  Do we have anyone in any
way active with Arcnet other than this guy?

One problem with the patch though.

> diff -puN include/linux/if_ether.h~arcnet-fixes include/linux/if_ether.h
> --- 25/include/linux/if_ether.h~arcnet-fixes	2004-10-28 00:17:07.230704752 -0700
> +++ 25-akpm/include/linux/if_ether.h	2004-10-28 00:17:07.247702168 -0700
> @@ -91,6 +91,7 @@
>  #define ETH_P_IRDA	0x0017		/* Linux-IrDA			*/
>  #define ETH_P_ECONET	0x0018		/* Acorn Econet			*/
>  #define ETH_P_HDLC	0x0019		/* HDLC frames			*/
> +#define ETH_P_ARCNET	0x0020		/* ArcNet			*/

You should use 0x001a or similar, so you don't have
to do this next part of your patch, bumping NPROTO
in net.h

> diff -puN include/linux/net.h~arcnet-fixes include/linux/net.h
> --- 25/include/linux/net.h~arcnet-fixes	2004-10-28 00:17:07.232704448 -0700
> +++ 25-akpm/include/linux/net.h	2004-10-28 00:17:07.248702016 -0700
> @@ -26,7 +26,7 @@
>  struct poll_table_struct;
>  struct inode;
>  
> -#define NPROTO		32		/* should be enough for now..	*/
> +#define NPROTO		33		/* should be enough for now..	*/
>  
>  #define SYS_SOCKET	1		/* sys_socket(2)		*/
>  #define SYS_BIND	2		/* sys_bind(2)			*/
