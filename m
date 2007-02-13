From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: /proc/sys/net/ipv[46]/conf/ issue unsolved
Date: Tue, 13 Feb 2007 09:02:24 -0800
Message-ID: <20070213090224.2826859f@localhost.localdomain>
References: <200702131529.04708.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hasso Tepper <hasso@estpak.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:44424 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750867AbXBMRCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 12:02:52 -0500
In-Reply-To: <200702131529.04708.hasso@estpak.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Feb 2007 15:29:04 +0200
Hasso Tepper <hasso@estpak.ee> wrote:

> There is long standing issue in kernel which makes using /etc/sysctl.conf
> useless for boottime configuration of specific interface properties and
> breaks probably any software relying on unconditional existence of the
> conf trees like it was in previous kernels (I alone have written several
> pieces of such software). It's broken AFAIK from 2.6.15. There has been
> several notes about issue in the list, but issue haven't got any (at least
> efficient) attention from developers.
> 
> The current behaviour bites users in many ways and breaks several use cases.
> I asked several times in the past "what I should do now?" question, but
> got no clear answer.
> 
> References:
> http://marc.theaimsgroup.com/?l=linux-netdev&m=115685059625467&w=2
> http://marc.theaimsgroup.com/?l=linux-netdev&m=115690828822486&w=2
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=169809
> 
> Is there any chance this will be fixed or at least clear position is
> taken by developers? Breaking userspace applications is declared nonono
> several times in the past ... I'm not even against breaking it if there
> is _very_ good reason to do it. Ok, but I want to know how userspace is
> meant to behave now. I can't continue using crappy workarounds.

As Herbert Xu said:

> You can disable it in /proc/sys/net/ipv6/conf/default/... and then
> reenable it on the interfaces that you actually want.

And Xen is broken because it tries to use the same bogus Mac
address on on all pseudo devices.


