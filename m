From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [-mm patch] net/dccp/ipv4.c: make struct dccp_v4_prot static
Date: Sat, 25 Feb 2006 11:31:01 -0300
Message-ID: <39e6f6c70602250631kef5adb7r7e0558733b9d2c9d@mail.gmail.com>
References: <20060224031002.0f7ff92a.akpm@osdl.org>
	 <20060225132729.GP3674@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Andrew Morton" <akpm@osdl.org>, davem@davemloft.net,
	acme@conectiva.com.br, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030253AbWBYObE@vger.kernel.org>
To: "Adrian Bunk" <bunk@stusta.de>
In-Reply-To: <20060225132729.GP3674@stusta.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/25/06, Adrian Bunk <bunk@stusta.de> wrote:
> On Fri, Feb 24, 2006 at 03:10:02AM -0800, Andrew Morton wrote:
> >...
> > Changes since 2.6.16-rc4-mm1:
> >...
> >  git-net.patch
> >...
> >  git trees.
> >...
>
>
> There's no reason for struct dccp_v4_prot being global.
>
>
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
>
> --- linux-2.6.16-rc4-mm2-full/net/dccp/ipv4.c.old       2006-02-25 04:32:45.000000000 +0100
> +++ linux-2.6.16-rc4-mm2-full/net/dccp/ipv4.c   2006-02-25 04:32:53.000000000 +0100
> @@ -1022,7 +1022,7 @@
>         .twsk_obj_size  = sizeof(struct inet_timewait_sock),
>  };
>
> -struct proto dccp_v4_prot = {
> +static struct proto dccp_v4_prot = {
>         .name                   = "DCCP",
>         .owner                  = THIS_MODULE,
>         .close                  = dccp_close,

Heck, the last series of patches were exactly to separate ipv4/ipv6 in
DCCP more clearly, how could I forget the cherry on top (sticking this static
in front of dccp_v4_prot)?

Eagle eyes indeed.

Thanks.

- Arnaldo
