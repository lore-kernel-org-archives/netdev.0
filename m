From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bug 16572] random panics in bridging on 2.6.34+
Date: Fri, 18 Mar 2011 09:03:38 -0700
Message-ID: <20110318090338.2f6dcb5d@nehalam>
References: <bug-16572-100@https.bugzilla.kernel.org/>
	<201103181349.p2IDn3Qm024329@demeter2.kernel.org>
	<20110318081052.6ca134fb@nehalam>
	<20110318152728.GA22053@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60190 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756926Ab1CRQEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 12:04:54 -0400
In-Reply-To: <20110318152728.GA22053@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Mar 2011 10:27:28 -0500
Herbert Xu <herbert@gondor.hengli.com.au> wrote:

> On Fri, Mar 18, 2011 at 08:10:52AM -0700, Stephen Hemminger wrote:
> > On Fri, 18 Mar 2011 13:49:03 GMT
> > bugzilla-daemon@bugzilla.kernel.org wrote:
> > 
> > > https://bugzilla.kernel.org/show_bug.cgi?id=16572
> >
> > Herbert hasn't submitted the patch upstream.
> 
> Oops! Thanks for reminding me.
> 
> bridge: Reset IPCB when entering IP stack on NF_FORWARD
> 
> Whenever we enter the IP stack proper from bridge netfilter we
> need to ensure that the skb is in a form the IP stack expects
> it to be in.
> 
> The entry point on NF_FORWARD did not meet the requirements of
> the IP stack, therefore leading to potential crashes/panics.
> 
> This patch fixes the problem.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
