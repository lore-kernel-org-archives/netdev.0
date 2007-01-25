From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: decnet handle a failure in neigh_parms_alloc
 (take 2)
Date: Thu, 25 Jan 2007 15:52:25 -0800 (PST)
Message-ID: <20070125.155225.71089715.davem@davemloft.net>
References: <20070124.144952.02299886.davem@davemloft.net>
	<m1irevzovi.fsf_-_@ebiederm.dsl.xmission.com>
	<20070125114318.GA4612@fogou.chygwyn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	patrick@tykepenguin.com
To: steve@chygwyn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42610
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030649AbXAYXw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 18:52:26 -0500
In-Reply-To: <20070125114318.GA4612@fogou.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Whitehouse <steve@chygwyn.com>
Date: Thu, 25 Jan 2007 11:43:18 +0000

> Hi,
> 
> On Wed, Jan 24, 2007 at 09:55:45PM -0700, Eric W. Biederman wrote:
> > 
> > While enhancing the neighbour code to handle multiple network
> > namespaces I noticed that decnet is assuming neigh_parms_alloc
> > will allways succeed, which is clearly wrong.  So handle the
> > failure.
> > 
> > Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> Acked-by: Steven Whitehouse <steve@chygwyn.com>

Applied, thanks everyone.

> Also you should cc Patrick as he is now the maintainer,

Yep, would be a good idea in the future.
