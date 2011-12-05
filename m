From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 tx watchdog timeout with 1Gb speed
Date: Mon, 5 Dec 2011 08:16:11 -0800
Message-ID: <20111205081611.52ec0664@nehalam.linuxnetplumber.net>
References: <20111120232118.GA29748@ntm.wq.cz>
	<20111121160543.2ae9c04c@nehalam.linuxnetplumber.net>
	<20111122094234.GA28500@ntm.wq.cz>
	<20111126161513.GA5299@ntm.wq.cz>
	<20111126170331.744025f1@s6510.linuxnetplumber.net>
	<20111205124725.GA19385@ntm.wq.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Milan Kocian <milon@wq.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37842 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932447Ab1LEQQO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 11:16:14 -0500
In-Reply-To: <20111205124725.GA19385@ntm.wq.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 5 Dec 2011 13:47:25 +0100
Milan Kocian <milon@wq.cz> wrote:

> On Sat, Nov 26, 2011 at 05:03:31PM -0800, Stephen Hemminger wrote:
> > 
> > I think the problem might be that the board doesn't really have all the DMA pins
> > wired. You might try enabling iommu, or limiting to <4G of memory.
> 
> hello stephen,
> 
> you are probably right. I found that with this mb (Gigabyte GA-965GM-S2) was
> more problems with linux. So I replaced this old crap with new one :-).
> Many thanks for your time.
> 
> Best regards,

There was a similar glitch with some skge users.

I have a patch to limit driver to 32bit only. If you send the DMI information,
it can be made automatic.
