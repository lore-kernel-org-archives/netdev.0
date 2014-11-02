From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [PATCH]  net: mvpp2: fix possible memory leak
Date: Sun, 2 Nov 2014 11:49:18 +0530
Message-ID: <20141102061918.GA2400@sudip-PC>
References: <1414841374-30537-1-git-send-email-sudipm.mukherjee@gmail.com>
 <20141101232445.1a3fe27e@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Marcin Wojtas <mw@semihalf.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:60071 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763AbaKBGTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2014 01:19:30 -0500
Content-Disposition: inline
In-Reply-To: <20141101232445.1a3fe27e@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 01, 2014 at 11:24:45PM +0100, Thomas Petazzoni wrote:
> Dear Sudip Mukherjee,
> 
> On Sat,  1 Nov 2014 16:59:34 +0530, Sudip Mukherjee wrote:
> > we are allocating memory using kzalloc for struct mvpp2_prs_entry,
> > but later when we are getting error we were just returning the error
> > value without releasing the memory.
> > 
> > Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
> > ---
> > 
> > hi,
> > i could not build test after modifying it. I tried to compile using
> > multi_v7_defconfig , but the cross compiler i have is not able to
> > compile it and giving sevaral warnings from the assembler.
> 
> That seems weird. Which compiler are you using, and which errors were
> you getting?
> 
> In any case, it would have been good to Cc the authors of the driver.
yes, i should have. Ccing now. better late than never.
i am using gcc version 4.3.2 (Sourcery G++ Lite 2008q3-72).

thanks
sudip

> 
> Thanks!
> 
> Thomas
> -- 
> Thomas Petazzoni, CTO, Free Electrons
> Embedded Linux, Kernel and Android engineering
> http://free-electrons.com
