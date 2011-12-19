From: Nicolas Pitre <nico@fluxnic.net>
Subject: Re: [PATCH] ARM: net: JIT compiler for packet filters
Date: Mon, 19 Dec 2011 12:31:19 -0500 (EST)
Message-ID: <alpine.LFD.2.02.1112191226160.2907@xanadu.home>
References: <1324252185-15894-1-git-send-email-mgherzan@gmail.com>
 <4EEEA644.5010008@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Mircea Gherzan <mgherzan@gmail.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:14443 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477Ab1LSRbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 12:31:20 -0500
Received: from xanadu.home ([66.130.28.92]) by VL-VM-MR003.ip.videotron.ca
 (Oracle Communications Messaging Exchange Server 7u4-22.01 64bit (built Apr 21
 2011)) with ESMTP id <0LWG00G7IOM9ODF0@VL-VM-MR003.ip.videotron.ca> for
 netdev@vger.kernel.org; Mon, 19 Dec 2011 12:30:09 -0500 (EST)
In-reply-to: <4EEEA644.5010008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 18 Dec 2011, Rob Herring wrote:

> On 12/18/2011 05:49 PM, Mircea Gherzan wrote:
> > +	select HAVE_BPF_JIT if (!THUMB2_KERNEL && AEABI)
> 
> No thumb2. That's a shame...

I think this would be more sensible to make a Thumb2 kernel properly 
interoperate with this and keep the JIT code simple rather than having 
to duplicate all this for Thumb2.

> BLX is v5+ only. It probably fine to make the JIT v5+ only. There's
> probably not much v4 h/w that would use this.

While you might be right, I don't think it is that big a cost to make 
this support ARMv4 too.  In fact, if slow ARMv4 systems are still 
routing packets out there, they are likely to see a huge benefit from 
this.


Nicolas
