From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH]atl1e:fix bug [Bug 11454] New: atl1e - BUG: scheduling while atomic: modprobe/678/0x00000002
Date: Sat, 30 Aug 2008 23:08:47 -0600
Message-ID: <20080831050837.GK1239@parisc-linux.org>
References: <12201583182726-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, bugme-daemon@bugzilla.kernel.org,
	harn-solo@gmx.de, jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jie.yang@atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:49855 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbYHaFKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2008 01:10:25 -0400
Content-Disposition: inline
In-Reply-To: <12201583182726-git-send-email-jie.yang@atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 31, 2008 at 12:51:58PM +0800, jie.yang@atheros.com wrote:
> from Jie Yang <jie.yang@atheros.com>
> 
>  On Saturday, August 30, 2008 5:27 AM
>  Andrew Morton <akpm@linux-foundation.org]>
> > On Fri, 29 Aug 2008 14:08:09 -0700 (PDT) 
> > bugme-daemon@bugzilla.kernel.org wrote:
> > 
> > > http://bugzilla.kernel.org/show_bug.cgi?id=11454
> > >
> > >            Summary: atl1e - BUG: scheduling while atomic:
> > >                     modprobe/678/0x00000002
> > >            Product: Drivers
> > >            Version: 2.5
> > >      KernelVersion: 2.6.27-rc5
> > >           Platform: All
> > >         OS/Version: Linux
> > >               Tree: Mainline
> > >             Status: NEW
> > >           Severity: high
> > >           Priority: P1
> > >          Component: Network
> > >         AssignedTo: jgarzik@pobox.com

How about taking my original patch, sent August 12th instead?  That has
a good changelog and proper attribution.  The removal of the
unnecessary casts can be a separate message.

If you weren't cc'd on the patch (Jeff was), you can pick it up from
netdev.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
