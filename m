From: Srihari Vijayaraghavan <harisri@bigpond.com>
Subject: Re: [patch 0/3] 2.6.5-netdev2 - r8169 update
Date: Wed, 14 Apr 2004 09:42:12 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404140942.12659.harisri@bigpond.com>
References: <20040405235545.A20805@electric-eye.fr.zoreil.com> <20040407231332.A25021@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Srihari Vijayaraghavan <harisri@telstra.com>,
        Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040407231332.A25021@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Francois,

On Thursday 08 April 2004 07:13, Francois Romieu wrote:
> The following serie of patches applies against 2.6.5 + 2.6.5-netdev2.
>
> - r8169-missing-static.patch
>   missing 'static' qualifiers.
>
> - r8169-irq-handler-status.patch
>   fix status code bogosity for the irq handler if the r8169 interrupt is
>   shared.
>
> - r8169-mod_timer.patch
>   missing "jiffies +" in mod_timer(). The link recovery code seems to work
>   again.
>
> An update of the patch against 2.6.5 for the whole driver is available for
> testers at:
> http://www.fr.zoreil.com/people/francois/misc/20040407-2.6.5-r8169.c-stable
>.patch

I have tested this under moderate network load on my Athlon 64 (2.6.5 64 bit 
kernel). It is working fine.

Thanks
Hari
