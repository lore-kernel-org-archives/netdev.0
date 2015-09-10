From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 09/13] Hide bp_type_idx behind #ifdef __KERNEL__
Date: Thu, 10 Sep 2015 12:11:15 +0100
Message-ID: <18025.1441883475@warthog.procyon.org.uk>
References: <1441832902-28993-10-git-send-email-palmer@dabbelt.com> <2644177.lVCYzIBfPW@wuerfel> <1441832902-28993-1-git-send-email-palmer@dabbelt.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, arnd@arndb.de, 3chas3@gmail.com,
	hpa@zytor.com, mingo@redhat.com, plagnioj@jcrosoft.com,
	jikos@kernel.org, linux-api@vger.kernel.org,
	linux-arch@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	linux-fbdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, tglx@linutronix.de, tomi.valkeinen@ti.com,
	x86@kernel.org
To: Palmer Dabbelt <palmer@dabbelt.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1441832902-28993-10-git-send-email-palmer@dabbelt.com>
Content-ID: <18024.1441883475.1@warthog.procyon.org.uk>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Palmer Dabbelt <palmer@dabbelt.com> wrote:

> +#ifdef __KERNEL__
>  enum bp_type_idx {
>  	TYPE_INST 	= 0,
> -#ifdef CONFIG_HAVE_MIXED_BREAKPOINTS_REGS
> +#if defined(CONFIG_HAVE_MIXED_BREAKPOINTS_REGS)
>  	TYPE_DATA	= 0,
>  #else
>  	TYPE_DATA	= 1,
>  #endif
>  	TYPE_MAX
>  };
> +#endif /* __KERNEL__ */

This should be in include/linux/hw_breakpoint.h without __KERNEL__ markings.

David
