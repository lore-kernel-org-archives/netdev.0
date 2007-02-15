From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: FC5 iptables-restore failure
Date: Thu, 15 Feb 2007 03:36:07 -0800
Message-ID: <20070215033607.6e984ebf.akpm@linux-foundation.org>
References: <20070215024507.8c97ee01.akpm@linux-foundation.org>
	<20070215112022.GD8353@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:44375 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965671AbXBOLgW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 06:36:22 -0500
In-Reply-To: <20070215112022.GD8353@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Feb 2007 06:20:22 -0500 Dave Jones <davej@redhat.com> wrote:

> On Thu, Feb 15, 2007 at 02:45:07AM -0800, Andrew Morton wrote:
>  > 
>  > I've recently been noticing nasty messages come out of FC5:
>  > 
>  > sony:/home/akpm# service iptables stop
>  > Flushing firewall rules:                                   [  OK  ]
>  > Setting chains to policy ACCEPT: filter                    [  OK  ]
>  > Unloading iptables modules:                                [  OK  ]
>  > sony:/home/akpm# service iptables start
>  > Applying iptables firewall rules: iptables-restore: line 20 failed
>  >                                                            [FAILED]
>  > 
>  > Dunno when it started happening, but it's in mainline now.
>  > 
>  > It's a pretty stupid error message.  line 20 of what?
> 
> 2.6.18 -> 2.6.19 changes a bunch of netfilter config option names.

whee-lets-break-peoples-firewalls?

> Sure you weren't bitten by that ?

Darned if I know.
