From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 5/8] smc91x: add SMC91X_IO_SHIFT* macros and make
 SMC_IO_SHIFT a variable
Date: Tue, 24 Jun 2008 00:15:47 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0806240005370.2979@xanadu.home>
References: <485A3E0B.1080505@gmail.com>
 <alpine.LFD.1.10.0806191223390.2982@xanadu.home> <485B2850.5050004@gmail.com>
 <alpine.LFD.1.10.0806200754030.23059@xanadu.home> <4860663D.9040606@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	Magnus Damm <magnus.damm@gmail.com>
To: Eric Miao <eric.y.miao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:39209 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbYFXEPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 00:15:48 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR005.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0K2Y00C5Y95O3OB0@VL-MO-MR005.ip.videotron.ca> for
 netdev@vger.kernel.org; Tue, 24 Jun 2008 00:15:24 -0400 (EDT)
In-reply-to: <4860663D.9040606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Jun 2008, Eric Miao wrote:

> Nicolas Pitre wrote:
> > That's not acceptable as an argument to introduce what actually is a 
> > regression, especially when it should be possible to avoid it.  And the 
> > fact is that there are already designs out there using this chip in 
> > production, serious or not.
> > 
> 
> OK, so is it arguable that boards like lubbock/mainstone/zylonite/littleton
> can be switched over to use the SMC_IO_SHIFT as a variable and leave other
> platforms unchanged due to the fact that these boards are just development
> platforms and do not care much about performance?

As long as the variable is not used for all 
configurations unconditionally so it is still possible to have a fixed 
config where everything is optimized at compile time.


Nicolas
