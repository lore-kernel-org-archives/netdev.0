From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 13760] New: 2.6.30 kernel locks up with pppoe
 in back trace (regression)
Date: Thu, 23 Jul 2009 09:15:23 -0700 (PDT)
Message-ID: <20090723.091523.180916751.davem@davemloft.net>
References: <20090722134557.2457c5f5.akpm@linux-foundation.org>
	<43d009740907222339n50ebe411ya6453dc5a294b9a0@mail.gmail.com>
	<20090723000100.d74d6b1c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: for.poige+bugzilla.kernel.org@gmail.com,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51927
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752581AbZGWQPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 12:15:17 -0400
In-Reply-To: <20090723000100.d74d6b1c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 23 Jul 2009 00:01:00 -0700

> Below is a ppp fix from 2.6.31, but it seems unlikely to fix your problem.

Andrew, that change was reverted, it's a NOP in the current tree.

There were various TTY layer fixups from Alan that could effect
PPP and related drivers.
