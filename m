From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] m68k/atari: EtherNEC - rewrite to use mainstream ne.c,
 take two
Date: Tue, 03 Apr 2012 18:52:58 -0400 (EDT)
Message-ID: <20120403.185258.615687289840688093.davem@davemloft.net>
References: <CAMuHMdX=4Vn=OsNTp04YcrhDOwz8NOFrWKankj2+3utvEfE-2A@mail.gmail.com>
	<4F5A0679.1020604@windriver.com>
	<4F7816B0.3090802@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, geert@linux-m68k.org,
	linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: schmitzmic@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39276 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755762Ab2DCWyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 18:54:06 -0400
In-Reply-To: <4F7816B0.3090802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Schmitz <schmitzmic@googlemail.com>
Date: Sun, 01 Apr 2012 20:49:52 +1200

> Hi Paul, Geert,
>> And on re-reading the comments in the other part of the patch, i.e.
>> "...emulates the card interrupt via a timer"  --perhaps the driver
>> should be just fixed to support generic netpoll, instead of adding
>> an arch specific thing that amounts to netpoll.  Then anyone can
>> attempt to limp along and use one of these ancient relics w/o IRQ.
>>   
> Here's take two of my patch to convert the m68k Atari ROM port
> Ethernet driver to use mainstream ne.c, with minimal changes to the
> core NE2000 code.

Please fix your email client, it corrupts your outgoing patches
by breaking up long lines with newlines amongst other things.
