From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv2 net-next] xfrm: Make xfrm_state timer monotonic
Date: Fri, 16 Aug 2013 11:30:18 +0200
Message-ID: <20130816093018.GM26773@secunet.com>
References: <1376552946-18967-1-git-send-email-fan.du@windriver.com>
 <20130815.142334.1736006937556027032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: fan.du@windriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55624 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754638Ab3HPJaW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 05:30:22 -0400
Content-Disposition: inline
In-Reply-To: <20130815.142334.1736006937556027032.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 15, 2013 at 02:23:34PM -0700, David Miller wrote:
> From: Fan Du <fan.du@windriver.com>
> Date: Thu, 15 Aug 2013 15:49:06 +0800
> 
> > xfrm_state timer should be independent of system clock change,
> > so switch to CLOCK_BOOTTIME base which is not only monotonic but
> > also counting suspend time.
> > 
> > Thus issue reported in commit: 9e0d57fd6dad37d72a3ca6db00ca8c76f2215454
> > ("xfrm: SAD entries do not expire correctly after suspend-resume")
> > could ALSO be avoided.
> > 
> > Signed-off-by: Fan Du <fan.du@windriver.com>
> > 
> > v2: Use CLOCK_BOOTTIME to count suspend time, but still monotonic.
> 
> This seems like a good fix:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Applied to ipsec-next, thanks!
