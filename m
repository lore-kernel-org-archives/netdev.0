From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-velocity: don't oops on MTU change.
Date: Fri, 16 Nov 2007 16:25:16 -0800 (PST)
Message-ID: <20071116.162516.45974449.davem@davemloft.net>
References: <20071115203508.4ad025f2@freepuppy.rosehill>
	<cccedfc60711160821p5f1790eaq8d385e71726cd5a0@mail.gmail.com>
	<20071116084706.467aa834@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jnelson@jamponi.net, jarkao2@o2.pl, akpm@linux-foundation.org,
	netdev@vger.kernel.org, jnelson-kernel-bugzilla@jamponi.net
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60919
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756849AbXKQAZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 19:25:22 -0500
In-Reply-To: <20071116084706.467aa834@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 16 Nov 2007 08:47:06 -0800

> On Fri, 16 Nov 2007 10:21:25 -0600
> "Jon Nelson" <jnelson@jamponi.net> wrote:
> 
> > I get a segmentation fault.
> > 
> > Should this patch be in addition to the one from bug 9382?
> > http://bugzilla.kernel.org/attachment.cgi?id=13555&action=view
> > 
> Yes. The new patch adds just recomputes the rx buf size in
> one place, so it can be set when device is down.
> Also, the computation will always yield same result now, the old
> code computed different values depending on whether it was initial
> or changed MTU.

But with your patch he is getting an OOPS (he described it as
a 'segmentation fault' which is why you perhaps missed it)
so you should try to figure out why so we can fix this bug.

:-)

Thanks.
