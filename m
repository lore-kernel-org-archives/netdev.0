From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] reciprocal_divide: correction/update of the
 algorithm
Date: Tue, 14 Jan 2014 11:50:32 -0800
Message-ID: <1389729032.31367.262.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140113214249.GK6586@order.stressinduktion.org>
	 <1389722825.31367.260.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52D58E6F.4050000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, dborkman@redhat.com,
	linux-kernel@vger.kernel.org, darkjames-ws@darkjames.pl
To: Austin S Hemmelgarn <ahferroin7@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:42752 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbaANTuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 14:50:35 -0500
In-Reply-To: <52D58E6F.4050000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-14 at 14:22 -0500, Austin S Hemmelgarn wrote:

> I disagree with the statement that current CPU's have reasonably fast
> dividers.  A lot of embedded processors and many low-end x86 CPU's do
> not in-fact have any hardware divider, and usually provide it using
> microcode based emulation if they provide it at all.  The AMD Jaguar
> micro-architecture in particular comes to mind, it uses an iterative
> division algorithm provided by the microcode that only produces 2 bits
> of quotient per cycle, even in the best case (2 8-bit integers and an
> integral 8-bit quotient) this still takes 4 cycles, which is twice as
> slow as any other math operation on the same processor.

I doubt you run any BPF filter with a divide instruction in it on these
platform.

Get real, do not over optimize things where it does not matter.
