From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Debugging TCP: Treason Uncloaked
Date: Tue, 13 May 2008 14:21:18 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805121637560.1888@wrl-59.cs.helsinki.fi>
References: <482265A0.8040105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Chris Bredesen <cbredesen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43812 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbYEMLVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 07:21:19 -0400
In-Reply-To: <482265A0.8040105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 May 2008, Chris Bredesen wrote:

> Hello,
> 
> As per below thread, I'm forwarding to this list/alias.  tcpdump output
> is attached to the forum post.
> 
> Thanks!
> 
> -------- Original Message --------
> Subject: Re: F8 Treason Uncloaked
> Date: Tue, 6 May 2008 20:00:51 +0100
> From: Alan Cox <alan@lxorguk.ukuu.org.uk>
> Organization: Red Hat UK Cyf., Amberley Place, 107-111 Peascod Street,
> Windsor, Berkshire, SL4 1TE, Y Deyrnas Gyfunol. Cofrestrwyd yng Nghymru
> a Lloegr o'r rhif cofrestru 3798903
> To: For users of Fedora <fedora-list@redhat.com>
> CC: cbredesen@redhat.com
> References: <4820A59F.7010005@redhat.com>
> 
> On Tue, 06 May 2008 14:38:23 -0400
> Chris Bredesen <cbredesen@redhat.com> wrote:
> 
> > Hello list,
> > 
> > I'm trying to get this issue out to a wider audience.  I posted it on the
> > forum but got no responses:
> > 
> > http://www.fedoraforum.org/forum/showthread.php?t=186331
> > 
> > Sorry to cross post, but I'm not sure where else to turn...
> 
> netdev@linux.kernel.org
> 
> but the TCP messages really indicate either a Linux bug or that the NAS
> isn't talking proper TCP. Trying turning off window scaling was a good
> test but beyond that tcpdump data will be needed.


...This report lacks kernel version (no I won't try to figure out what f8 
or whatever is using on your box, just tell it :-)) (e.g., ...Some 
2.6.25-rc had this problem).

Tcp_window_scaling sysctl has nothing to do with window resizing. ...It 
just decides if scaling factor can be used or not. It won't guarantee you 
a constant window!

What happened while the window was shrunk is hard to know because the log 
snippet doesn't have the point where the window was reduced.

-- 
 i.
