From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13760] New: 2.6.30 kernel locks up with pppoe
 in back trace (regression)
Date: Thu, 23 Jul 2009 10:51:41 -0700
Message-ID: <20090723105141.5272aee1.akpm@linux-foundation.org>
References: <20090722134557.2457c5f5.akpm@linux-foundation.org>
	<43d009740907222339n50ebe411ya6453dc5a294b9a0@mail.gmail.com>
	<20090723000100.d74d6b1c.akpm@linux-foundation.org>
	<20090723.091523.180916751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: for.poige+bugzilla.kernel.org@gmail.com,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60880 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753261AbZGWRwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 13:52:15 -0400
In-Reply-To: <20090723.091523.180916751.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Jul 2009 09:15:23 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Thu, 23 Jul 2009 00:01:00 -0700
> 
> > Below is a ppp fix from 2.6.31, but it seems unlikely to fix your problem.
> 
> Andrew, that change was reverted, it's a NOP in the current tree.
> 
> There were various TTY layer fixups from Alan that could effect
> PPP and related drivers.

I wouldn't have thought that pppoe would be affected by tty changes?

As opposed to pppotty :)
