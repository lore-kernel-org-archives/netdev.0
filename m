From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NetLabel: Verify sensitivity level has a valid CIPSO
 mapping
Date: Fri, 02 Mar 2007 13:19:45 -0800 (PST)
Message-ID: <20070302.131945.70218355.davem@davemloft.net>
References: <20070228200140.491071752@hp.com>
	<Line.LNX.4.64.0702281544350.9150@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, netdev@vger.kernel.org
To: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38814
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965652AbXCBVTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 16:19:46 -0500
In-Reply-To: <Line.LNX.4.64.0702281544350.9150@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Wed, 28 Feb 2007 15:45:07 -0500 (EST)

> On Wed, 28 Feb 2007, Paul Moore wrote:
> 
> > The current CIPSO engine has a problem where it does not verify that the given
> > sensitivity level has a valid CIPSO mapping when the "std" CIPSO DOI type is
> > used.  The end result is that bad packets are sent on the wire which should
> > have never been sent in the first place.  This patch corrects this problem by
> > verifying the sensitivity level mapping similar to what is done with the
> > category mapping.  This patch also changes the returned error code in this case
> > to -EPERM to better match what the category mapping verification code returns.
> > 
> > Signed-off-by: Paul Moore <paul.moore@hp.com>
> 
> [removed redhat-lspp, which is subscriber only]
> 
> Acked-by: James Morris <jmorris@namei.org>

Applied, thanks everyone.

If -stable inclusion is desired, please submit this patch there.
You can add my signoff if you want:

Signed-off-by: David S. Miller <davem@davemloft.net>
