From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net: xfrm6: silence sparse warning
Date: Fri, 10 Jan 2014 02:53:06 +0000
Message-ID: <1389322386.2728.66.camel@deadeye.wl.decadent.org.uk>
References: <1389149801-29011-1-git-send-email-ying.xue@windriver.com>
	 <20140107.224357.1577838150943921013.davem@davemloft.net>
	 <52CCE83D.5080909@windriver.com>
	 <20140108.005656.1582987448512057112.davem@davemloft.net>
	 <20140109150451.30b57b2b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <ying.xue@windriver.com>,
	<steffen.klassert@secunet.com>, <dborkman@redhat.com>,
	<netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41556 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753487AbaAJCxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 21:53:09 -0500
In-Reply-To: <20140109150451.30b57b2b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-09 at 15:04 -0800, Stephen Hemminger wrote:
> On Wed, 08 Jan 2014 00:56:56 -0500 (EST)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Ying Xue <ying.xue@windriver.com>
> > Date: Wed, 8 Jan 2014 13:55:09 +0800
> > 
> > > 3. Just drop the patch
> > 
> > This is the only suitable thing to do.
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> There was some patches floating around to eliminate uses of variable
> length array in the kernel since they aren't supported by CLANG.

I think you're mixing up two different things there.  VLAs are part of
C99 so I'm quite sure Clang supports them (in general).  But they seem
to be deprecated in the kernel anyway, maybe because they make it easy
to introduce a stack overflow.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
