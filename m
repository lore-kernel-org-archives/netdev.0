From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH] [2.4] forcedeth network driver
Date: Sat, 24 Jan 2004 20:02:10 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4012C132.5090508@colorfullife.com>
References: <4012A738.2060009@gmx.net> <20040124195951.A1304@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>,
        marcelo.tosatti@cyclades.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040124195951.A1304@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:

>-> get_npriv() can still dereference a NULL pointer.
>  
>
Ups, I think I fixed that. It seems the fix got lost. Sorry.

>+       if (!dev->base_addr)
>+               goto out_disable;
>                     ^^^^^^^^^^^
>-> shouldn't it be out_relreg ?
>  
>
Ok, thanks.

--
    Manfred
