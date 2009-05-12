From: Michael Riepe <michael.riepe@googlemail.com>
Subject: Re: 2.6.27.19 + 28.7: network timeouts for r8169 and 8139too
Date: Tue, 12 May 2009 22:29:50 +0200
Message-ID: <4A09DC3E.2080807@googlemail.com>
References: <200903041828.49972.m.bueker@berlin.de> <1242001754.4093.12.camel@obelisk.thedillows.org> <200905112248.44868.mb@bu3sch.de> <200905112310.08534.mb@bu3sch.de> <1242077392.3716.15.camel@lap75545.ornl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	=?ISO-8859-15?Q?Michael_B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:57715 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbZELU3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 16:29:53 -0400
In-Reply-To: <1242077392.3716.15.camel@lap75545.ornl.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

David Dillow wrote:

> I was saying that I don't think the timeouts are necessarily the NIC
> chipset -- or the bridge chip for that matter --  having issues with
> MSI. There were some substantial IRQ handling changes in 2.6.28 and my
> bisection of the problem seem to lead into that code. I'll try this
> later tonight hopefully, but can you try to run 2.6.27 with the current
> r8169 driver and see if it is solid for you? That way it is using the
> same driver code, but avoids the IRQ changes.

Unfortunately, 2.6.27 won't build with r8169.c copied from 2.6.29.

-- 
Michael "Tired" Riepe <michael.riepe@googlemail.com>
X-Tired: Each morning I get up I die a little
