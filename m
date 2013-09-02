From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next v12 06/11] vxlan: add ipv6 support
Date: Mon, 02 Sep 2013 09:17:48 +0800
Message-ID: <1378084668.2169.1.camel@cr0>
References: <1377927878-23975-1-git-send-email-amwang@redhat.com>
	 <1377927878-23975-7-git-send-email-amwang@redhat.com>
	 <20130831102726.21896150@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16108 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752366Ab3IBBS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Sep 2013 21:18:56 -0400
In-Reply-To: <20130831102726.21896150@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-08-31 at 10:27 -0700, Stephen Hemminger wrote:
> On Sat, 31 Aug 2013 13:44:33 +0800
> Cong Wang <amwang@redhat.com> wrote:
> 
> > +#if IS_ENABLED(CONFIG_IPV6)
> > +	} else {
> > +		ipv6_stub->ipv6_sock_mc_join(sk, ifindex,
> > +					     &ip->sin6.sin6_addr);
> > +#endif
> 
> This isn't safe against IPv6 module getting unloaded. You either
> have to figure out a reference count method, or disable IPv6
> module unload.
> 
> Since it can only be forced unload anyway, I still argue
> it should just be disabled (by removing the module exit hook
> and code).

I will send a patch to remove ipv6 module exit code, since there is
other problem too.

Thanks!
