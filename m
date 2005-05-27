From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] baycom_epp.c: Fix compilation with gcc-4.1.0-20050522
Date: Fri, 27 May 2005 08:53:22 -0700
Message-ID: <20050527085322.35e312cf@dxpl.pdx.osdl.net>
References: <200505271808.32032.adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Thomas Sailer <t.sailer@alumni.ethz.ch>
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <200505271808.32032.adobriyan@gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 27 May 2005 18:08:31 +0400
Alexey Dobriyan <adobriyan@gmail.com> wrote:

> drivers/net/hamradio/baycom_epp.c:432: error: jump into statement expression
> 	...
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> 
> --- linux-vanilla/drivers/net/hamradio/baycom_epp.c	2005-05-27 12:58:48.000000000 +0400
> +++ linux-gcc4/drivers/net/hamradio/baycom_epp.c	2005-05-27 17:54:14.000000000 +0400
> @@ -380,22 +380,18 @@ static inline void do_kiss_params(struct
>   */
>  
>  #define ENCODEITERA(j)                         \
> -({                                             \
>          if (!(notbitstream & (0x1f0 << j)))    \
>                  goto stuff##j;                 \
> -  encodeend##j:    	;                      \
> -})
> +  encodeend##j:    	;

Ick... Please just kill this kind of macro crap
