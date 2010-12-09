From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Fix 2.6.34-rc1 regression in disable_ipv6 support
Date: Thu, 9 Dec 2010 14:51:43 -0800
Message-ID: <20101209145143.5c45cf60@nehalam>
References: <4D00F58A.2050307@hp.com>
	<m139q6ahld.fsf@fess.ebiederm.org>
	<20101209111611.1d2e6e2b@nehalam>
	<20101209.122033.183046393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, brian.haley@hp.com, netdev@vger.kernel.org,
	maheshkelkar@gmail.com, lorenzo@google.com,
	yoshfuji@linux-ipv6.org, stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57296 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752114Ab0LIWvs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 17:51:48 -0500
In-Reply-To: <20101209.122033.183046393.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 09 Dec 2010 12:20:33 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 9 Dec 2010 11:16:11 -0800
> 
> > No but since removing address propagates up to user space daemons
> > like Quagga please analyze and fix the problem, don't just look
> > for band aid.
> 
> Stephen, we lived with the previous behavior for 12+ years.
> 
> You broke stuff that did work before your change.
> 
> Putting the onus on Eric to fix it exactly how you want it to
> be fixed is therefore not appropriate.
> 
> You seem to be putting exactly zero effort into trying to reproduce
> the problem yourself and fixing a bug you introduced.  And hey we
> have a standard way to deal with a regression when the guilty party
> is uncooperative, revert.
> 
> There are therefore three choices:
> 
> 1) Revert.  And this is the one I'm favoring because of how you are
>    handling this issue.  The responsibility to resolve this regression
>    is your's not Eric's.
> 
>    Frankly, Eric is being incredibly nice by working on trying to fix
>    a bug which you introduced.
> 
> 2) Accept Eric's proposed fix.
> 
> 3) Figure out the real bug yourself and fix the problem the way you
>    find acceptable in a reasonable, short, amount of time.
> 
> Loopback has always been special, especially on ipv6.  When we don't
> have a device to point something at, we point it at loopback.
> 
> Also destination cache entries which still have references when they
> get zapped get pointed at loopback.

Quit being a grinch. I am working on it, just don't know the answer.
I want to try a couple solutions, so far Eric's looks okay, just want
to make sure that it doesn't break anything.

You are over reacting. Doing on the fly re-enabling of ipv6 is a corner case.
The problem was only discovered a couple of days ago, it is not like
the world is burning down.


-- 
