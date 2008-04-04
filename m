From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2173	tcp_mark_head_lost+0x173/0x1a0()
Date: Fri, 4 Apr 2008 22:48:29 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804042244260.415@wrl-59.cs.helsinki.fi>
References: <20080402224137.GB25768@curie-int.orbis-terrarum.net>
 <20080403211913.3a0c1d00.akpm@linux-foundation.org>
 <20080403212038.ec0a4244.akpm@linux-foundation.org>
 <20080404082201.GC20121@curie-int.orbis-terrarum.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "Robin H. Johnson" <robbat2@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39997 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125AbYDDTsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 15:48:32 -0400
In-Reply-To: <20080404082201.GC20121@curie-int.orbis-terrarum.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Apr 2008, Robin H. Johnson wrote:

> On Thu, Apr 03, 2008 at 09:20:38PM -0700, Andrew Morton wrote:
> > On Thu, 3 Apr 2008 21:19:13 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > > 
> > > (cc netdev)
> > > 
> > > (and Rafael - I assume 2.6.24 didn't do this..)
> > 
> > urgh.
> > 
> > > On Wed, 2 Apr 2008 15:41:37 -0700 "Robin H. Johnson" <robbat2@gentoo.org> wrote:
> > > 
> > > > (Please CC, not on LKML).
> > > > 
> > > > One of the nodes in my web-serving cluster (isohunt.com) started showing this:
> > > > 
> > > > ------------[ cut here ]------------
> > > > WARNING: at net/ipv4/tcp_input.c:2173 tcp_mark_head_lost+0x173/0x1a0()
> > > > Modules linked in: lm85 hwmon_vid nfs lockd nfs_acl sunrpc bonding reiserfs k8temp hwmon i2c_nforce2 i2c_core sg
> > > > Pid: 32500, comm: php-cgi Not tainted 2.6.25-rc4-git2 #7
> > I misread that as -rc8.
> > We fixed a lot of stuff since -rc4.  Please retest current mainline?
> 
> Hopefully this is new enough. -git3 was released right while I was writing this
> email after testing, and I don't see anything in there that seems related.
> 
> ------------[ cut here ]------------
> WARNING: at net/ipv4/tcp_input.c:1771 tcp_enter_frto+0x2bb/0x2c0()

Is this _the first one_ you encounter? It's very strange place because
tcp_enter_frto won't touch those sacked_out / lost_out counters at all
so it hardly could cause an overflow there.



-- 
 i.
