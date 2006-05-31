From: Willy Tarreau <willy@w.ods.org>
Subject: Re: [PATCH-2.4] forcedeth update to 0.50
Date: Wed, 31 May 2006 21:43:45 +0200
Message-ID: <20060531194345.GA11807@w.ods.org>
References: <20060530220319.GA6945@w.ods.org> <447D2EA8.8020001@colorfullife.com> <20060531055438.GA9142@w.ods.org> <20060531180545.GA30797@dmt> <447DF38E.3020409@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcelo Tosatti <marcelo@kvack.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from willy.net1.nerim.net ([62.212.114.60]:23050 "EHLO
	willy.net1.nerim.net") by vger.kernel.org with ESMTP
	id S965155AbWEaT7s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 15:59:48 -0400
To: Manfred Spraul <manfred@colorfullife.com>
Content-Disposition: inline
In-Reply-To: <447DF38E.3020409@colorfullife.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 31, 2006 at 09:50:38PM +0200, Manfred Spraul wrote:
> Marcelo Tosatti wrote:
> 
> >Since v2.4.33 should be out RSN, my opinion is that applying the 
> >one-liner to fix the bringup problem for now is more prudent..
> >
> > 
> >
> It's attached. Untested, but it should work. Just the relevant hunk from 
> the 0.42 patch.

I will test it tomorrow morning. John might be interested in merging it too,
as I have checked today that RHEL3 was affected by the same problem (rmmod
followed by modprobe).

> But I would disagree with waiting for 2.3.34 for a full backport:
> 0.30 basically doesn't work, thus the update to 0.50 would be a big step 
> forward - it can't be worse that 0.30.

Seconded !
Manfred, if you have some corner cases in mind, are aware of anything which
might sometimes break, or have a few experimental patches to try, I'm OK for
a few tests while I have the machine (it's SMP BTW).

> --
>    Manfred

Cheers,
Willy

