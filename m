From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] net/atm: move all compat_ioctl handling to atm/ioctl.c
Date: Wed, 11 Nov 2009 13:34:50 +0000
Message-ID: <1257946490.25961.1396.camel@macbook.infradead.org>
References: <200911061500.01651.arnd@arndb.de>
	 <20091110.204118.12070030.davem@davemloft.net>
	 <200911111430.44361.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755589AbZKKNew@vger.kernel.org>
In-Reply-To: <200911111430.44361.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-11-11 at 14:30 +0100, Arnd Bergmann wrote:
> 
> +struct atmif_sioc32 {
> +       compat_int_t    number;
> +       compat_int_t    length;
> +       compat_caddr_t  arg;
> +};
> +
> +struct atm_iobuf32 {
> +       compat_int_t    length;
> +       compat_caddr_t  buffer;
> +}; 

We already have compat_atmif_sioc and compat_atm_iobuf structures
defined -- do those need to be duplicated?

Other than that, it looks sane. I wish I'd noticed that we already had
half a COMPAT implementation when I added the new bits. Thanks.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation
