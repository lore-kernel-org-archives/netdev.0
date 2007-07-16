From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] crash in 2.6.22-git2 sysctl_set_parent()
Date: Mon, 16 Jul 2007 14:55:30 -0700 (PDT)
Message-ID: <20070716.145530.51840998.davem@davemloft.net>
References: <20070713200515.GS5549@austin.ibm.com>
	<20070713.154702.17863636.davem@davemloft.net>
	<20070716172535.GB5771@austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52810
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764288AbXGPVz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 17:55:27 -0400
In-Reply-To: <20070716172535.GB5771@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: linas@austin.ibm.com (Linas Vepstas)
Date: Mon, 16 Jul 2007 12:25:35 -0500

> On Fri, Jul 13, 2007 at 03:47:02PM -0700, David Miller wrote:
> > From: linas@austin.ibm.com (Linas Vepstas)
> > Date: Fri, 13 Jul 2007 15:05:15 -0500
> > 
> > > 
> > > This is a patch (& bug report) for a crash in sysctl_set_parent() 
> > > in 2.6.22-git2. 
> > > 
> > > Problem: 2.6.22-git2 crashes with a stack trace 
> > > 
> > > Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> > 
> > Thanks for tracking this down, I'll apply your patch.
> 
> NAK. As I just explained in another email, this bug
> was introduced by the "send-to-self" patch I habitually
> apply -- so habitually, that I forgot I was not working 
> with a "clean" tree. So it goes ... 

I saw all of this, thanks.
