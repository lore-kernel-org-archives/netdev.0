From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: Tree for September 3
Date: Thu, 4 Sep 2008 15:22:48 -0700
Message-ID: <20080904152248.50773a6d.akpm@linux-foundation.org>
References: <20080903191619.6b6b230e.sfr@canb.auug.org.au>
	<20080903214634.ea17ff53.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809032201510.3378@nehalem.linux-foundation.org>
	<20080903223318.84b6ce8b.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809040045190.3378@nehalem.linux-foundation.org>
	<20080904012544.cabed847.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809040143350.3452@nehalem.linux-foundation.org>
	<20080904015701.5959623a.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809040203510.3452@nehalem.linux-foundation.org>
	<20080904104554.32ffebea.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809041058140.3400@nehalem.linux-foundation.org>
	<20080904113408.d47c65f6.akpm@linux-foundation.org>
	<m163pb4pru.fsf@frodo.ebiederm.org>
	<20080904134148.0fde4508.akpm@linux-foundation.org>
	<m1zlmn39oy.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	yhlu.kernel@gmail.com, ink@jurassic.park.msu.ru,
	jbarnes@virtuousgeek.org, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk, dwmw2@infradead.org, sam@ravnborg.org,
	johnstul@us.ibm.com, tglx@linutronix.de
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55252 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754622AbYIDWXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 18:23:40 -0400
In-Reply-To: <m1zlmn39oy.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 04 Sep 2008 14:03:41 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > On Thu, 04 Sep 2008 13:31:01 -0700
> > ebiederm@xmission.com (Eric W. Biederman) wrote:
> >
> >> >> are you sure it's a plain tree of mine, without any of the patches 
> >> >> floating around between Eric/Al?
> >> >
> >> > yup, it's yesterday's mainline.
> >> 
> >> Does the problem happen if you disable selinux?
> >> 
> >> This feels like a case of selinux being over zealous.
> >
> > yeah, adding `selinux=0' to the boot command line fixes it.
> 
> The proc generic directory back structure is the same.  As requested by
> the selinux folks.  So I don't expect there is much more we can do on
> the /proc side.
> 
> When we get the interaction bug between the VFS and /proc/net fixed I wonder
> if there will be some more selinux fall out.  Something to think about.

fyi, that machine is x86_32-on-FC5.  My x86_64-on-FC6 test box is
also running selinux and has the same bug.
