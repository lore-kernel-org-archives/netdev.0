From: Paul Moore <paul.moore@hp.com>
Subject: Re: [GIT]: Networking
Date: Thu, 11 Dec 2008 08:20:59 -0500
Message-ID: <200812110821.00002.paul.moore@hp.com>
References: <20081208.000655.211323914.davem@davemloft.net> <Pine.LNX.4.64.0812111344580.10515@vixen.sonytel.be>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Development <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:9649 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbYLKNVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 08:21:03 -0500
In-Reply-To: <Pine.LNX.4.64.0812111344580.10515@vixen.sonytel.be>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 11 December 2008 7:50:23 am Geert Uytterhoeven wrote:
> On Mon, 8 Dec 2008, David Miller wrote:
> > Here are the pending net fixes:
> >
> > 6) netlabel OOPS'er fix from Paul Moore.
> >
> > Paul Moore (1):
> >       netlabel: Fix a potential NULL pointer dereference
>
> This introduced:
> | net/netlabel/netlabel_unlabeled.c:567: warning: 'entry' may be used
> | uninitialized in this function
> | net/netlabel/netlabel_unlabeled.c:629: warning: 'entry' may be used
> | uninitialized in this function
>
> which may still oops, if the uninitialized entry pointer is
> dereferenced (in case list_entry == NULL).

Hi Geert,

First of, a quick question: what version of gcc are you using?  I'm 
using gcc-4.3.2 and I don't get this warning/error.  Regardless, I'll 
send out a patch later today which should resolve the warning.

-- 
paul moore
linux @ hp
