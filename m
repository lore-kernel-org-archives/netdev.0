From: Erkki Seppala <flux-lkml@inside.org>
Subject: Re: Tiny patch (w/ discussion) to provide the peer information on
 unix domain sockets
Date: Tue, 30 Mar 2010 20:39:04 +0300
Message-ID: <20100330173904.GB12709@coffee.modeemi.cs.tut.fi>
References: <1269961013.2012.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.cs.tut.fi ([130.230.4.42]:61798 "EHLO mail.cs.tut.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754329Ab0C3Rqi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 13:46:38 -0400
Received: from amavis1.cs.tut.fi (amavis1.cs.tut.fi [130.230.4.69])
	by mail.cs.tut.fi (Postfix) with ESMTP id AEE5D749
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 20:39:05 +0300 (EEST)
Received: from mail.cs.tut.fi ([130.230.4.42])
 by amavis1.cs.tut.fi (amavis1.cs.tut.fi [130.230.4.69]) (amavisd-maia, port 10024)
 with ESMTP id 14289-27 for <netdev@vger.kernel.org>;
 Tue, 30 Mar 2010 20:39:05 +0300 (EEST)
Received: from modeemi.modeemi.fi (modeemi.modeemi.fi [130.230.72.134])
	by mail.cs.tut.fi (Postfix) with ESMTP id 0C05E748
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 20:39:05 +0300 (EEST)
Received: from coffee.modeemi.fi (coffee.modeemi.fi [130.230.72.140])
	by modeemi.modeemi.fi (Postfix) with ESMTP id EEA313907F
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 20:39:04 +0300 (EEST)
Content-Disposition: inline
In-Reply-To: <1269961013.2012.61.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Tue, Mar 30, 2010 at 04:56:53PM +0200, Eric Dumazet wrote:
> Such patches should be sent to netdev

Oops! Thanks for the pointer!

> I believe you missed some necessary locking.

I don't think so, because I don't actually dereference the other unix
address, I just print the its address.

> Prior art from Kenan Kalajdzic :
> 
>  http://patchwork.ozlabs.org/patch/46561/

Perhaps this would be a more decent solution (using the more
user-space compatible concept of inodes), although I think don't that
the backwards compatiblity for this kind of rarely used feature is
that critical, given the impact of the breakage seems to be quite low
as well.

I think the way forward in general should be that user space
applications actually look what columns are available and provide
future compatibility in that fashion. And empty fields should have
have some filler :).

-- 
  _____________________________________________________________________
     / __// /__ ____  __               http://www.modeemi.fi/~flux/\   \
    / /_ / // // /\ \/ /                                            \  /
   /_/  /_/ \___/ /_/\_\@modeemi.fi                                  \/
