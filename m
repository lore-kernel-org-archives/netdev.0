From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] net: Remove a noisy printk
Date: Fri, 19 Dec 2008 11:51:54 +1030
Message-ID: <200812191151.55607.rusty@rustcorp.com.au>
References: <1229033625-30825-1-git-send-email-ajax@redhat.com> <alpine.DEB.2.00.0812141745550.2447@blackhole.kfki.hu> <20081214200353.GA2994@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jan Engelhardt <jengelh@medozas.de>,
	David Miller <davem@davemloft.net>, ajax@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Dave Jones <davej@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081214200353.GA2994@redhat.com>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 15 December 2008 06:33:53 Dave Jones wrote:
> On Sun, Dec 14, 2008 at 06:09:17PM +0100, Jozsef Kadlecsik wrote:
>  > In a >normal< system one usually does not use raw sockets. So if a root 
>  > process do use raw socket, at least netfilter sends a notification and 
>  > there's a chance that someone take notice it by checking the kernel logs.
> 
> 'normal' systems are irrelevant here. This message is triggerable remotely.

I don't think it can be.  This is for truncated locally-generated outgoing
packets, which can only happen when root is playing with raw sockets.

As you can probably tell, I was the one who wrote this printk :)  IMHO,
one reasonable complaint is sufficient to have it removed, so just remove
it.  If anyone thinks it's valuable, put a static counter < 5 around it
and add pid/comm info.

Cheers,
Rusty.
