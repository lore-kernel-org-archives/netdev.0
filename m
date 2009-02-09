From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG BISECTED] boot hangs while bringing up gianfar ethernet
Date: Mon, 9 Feb 2009 13:54:56 +0000
Message-ID: <20090209135456.GA6313@ff.dom.local>
References: <20090207225555.GA2680@ami.dom.local> <87prhr7mwg.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ira Snyder <iws@ovro.caltech.edu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Dai Haruki <dai.haruki@freescale.com>,
	Andy Fleming <afleming@freescale.com>
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:50380 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753630AbZBINzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 08:55:04 -0500
Content-Disposition: inline
In-Reply-To: <87prhr7mwg.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 09, 2009 at 02:36:15PM +0100, Peter Korsgaard wrote:
> >>>>> "Jarek" == Jarek Poplawski <jarkao2@gmail.com> writes:
> 
>  Jarek> Ira Snyder wrote, On 01/29/2009 08:41 PM:
>  >> Hello,
>  >> 
>  >> I'm working on a Freescale MPC8349EMDS board. I have been booting it
>  >> over NFS for a long time now. I try to run the latest git kernels to
>  >> find possible problems.
>  >> 
>  >> Recently, I haven't been able to boot over NFS anymore. When the machine
>  >> tries to bring up the ethernet interface, it just hangs forever. There
>  >> are no softlockup warnings, the machine has locked up completely.
>  >> 
>  >> Here is the commit I bisected it down to. I tried running git revert,
>  >> but there have been other changes which prevent an easy revert.
>  >> 
>  >> After building each kernel, I compiled and used the dts file from that
>  >> kernel. There shouldn't be any conflicts there.
> 
>  Jarek> Hi,
> 
>  Jarek> Could you try this patch?
> 
> Solves the problem for me - Thanks. I'm not familar enough with the hw
> to know if's the right fix, but it certainly fixes the nfsboot issue
> for me.

I guess a few more familiar eyes will have a look at it yet, but let's
wait for Ira first.

Thanks very much for testing,
Jarek P.
