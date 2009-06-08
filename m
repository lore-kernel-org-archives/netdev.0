From: Nicolas Pitre <nico@cam.org>
Subject: Re: SMC91x: forcing speed
Date: Mon, 08 Jun 2009 18:17:21 -0400 (EDT)
Message-ID: <alpine.LFD.2.00.0906081807410.31536@xanadu.home>
References: <ba4215e10906080502u3966a301vb2d7162f48694a4b@mail.gmail.com>
 <20090608.142257.141336772.davem@davemloft.net> <4A2D85D7.6050509@gmail.com>
 <20090608.144445.72867560.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: mfuzzey@gmail.com, richard.rojfors@endian.se,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:26407 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752833AbZFHWRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 18:17:24 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR002.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0KKX00GCAXWX6CD0@VL-MO-MR002.ip.videotron.ca> for
 netdev@vger.kernel.org; Mon, 08 Jun 2009 18:17:21 -0400 (EDT)
In-reply-to: <20090608.144445.72867560.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Jun 2009, David Miller wrote:

> From: Martin Fuzzey <mfuzzey@gmail.com>
> Date: Mon, 08 Jun 2009 23:42:47 +0200
> 
> > IMHO the place for board specific hacks is in the board specifc startup
> > code - am I wrong?
> 
> We never add bootup time hacks for things that already have
> a suitable generic and clean configuration interface.

Maybe suitable in a workstation setup.

> People ask for module options and all kinds of crap like that
> to set link parameters, and we always say no.

And this is probably why there is still a disconnect between mainline 
and embedded people.

For some systems, the simple notion of a special ramdisk just makes the 
whole thing 4 times more complex.

Wouldn't it be possible to accommodate those people with a generic 
ethtool module that simply interpret some kernel cmdline parameters in a 
uniform and maintainable way to apply some settings during kernel boot?


Nicolas
