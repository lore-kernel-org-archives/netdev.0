From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: lockdep possible recursive lock in slab parent->list->rlock in
 rc2
Date: Mon, 28 Dec 2009 10:40:03 +0100
Message-ID: <20091228094003.GA7607@osiris.boeblingen.de.ibm.com>
References: <20091227120622.GA480@basil.fritz.box>
 <1261917194.5933.2.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	a.p.zijlstra@chello.nl, cl@linux-foundation.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752018AbZL1JkR@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1261917194.5933.2.camel@penberg-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 27, 2009 at 02:33:14PM +0200, Pekka Enberg wrote:
> Hi Andi,
> 
> On Sun, 2009-12-27 at 13:06 +0100, Andi Kleen wrote:
> > Get this on a NFS root system while booting
> > This must be a recent change in the last week, 
> > I didn't see it in a post rc1 git* from last week
> > (I haven't done a exact bisect)
> > 
> > It's triggered by the r8169 driver close function, 
> > but looks more like a slab problem?
> > 
> > I haven't checked it in detail if the locks are 
> > really different or just lockdep not knowing 
> > enough classes.
> 
> I broke the lockdep annotations in commit
> ce79ddc8e2376a9a93c7d42daf89bfcbb9187e62 ("SLAB: Fix lockdep annotations
> for CPU hotplug"). Does this fix things for you? Heiko, the following
> patch should fix it for you too.

Works fine here too. Thanks!
