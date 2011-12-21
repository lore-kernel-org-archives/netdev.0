From: Mircea Gherzan <mgherzan@gmail.com>
Subject: Re: [PATCH] ARM: net: JIT compiler for packet filters
Date: Wed, 21 Dec 2011 16:36:03 +0200
Message-ID: <20111221143602.GA3229@swarm.cs.pub.ro>
References: <1324252185-15894-1-git-send-email-mgherzan@gmail.com>
 <4EEEA644.5010008@gmail.com>
 <alpine.LFD.2.02.1112191226160.2907@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robherring2@gmail.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk
To: Nicolas Pitre <nico@fluxnic.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:55932 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621Ab1LUOgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 09:36:12 -0500
Received: by eekc4 with SMTP id c4so7587250eek.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 06:36:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.02.1112191226160.2907@xanadu.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2011 at 12:31:19PM -0500, Nicolas Pitre wrote:
> On Sun, 18 Dec 2011, Rob Herring wrote:
> 
> > On 12/18/2011 05:49 PM, Mircea Gherzan wrote:
> > > +	select HAVE_BPF_JIT if (!THUMB2_KERNEL && AEABI)
> > 
> > No thumb2. That's a shame...
> 
> I think this would be more sensible to make a Thumb2 kernel properly 
> interoperate with this and keep the JIT code simple rather than having 
> to duplicate all this for Thumb2.

The JITed code interoperates properly with a Thumb2 kernel as of v3 of
the patch.

> > BLX is v5+ only. It probably fine to make the JIT v5+ only. There's
> > probably not much v4 h/w that would use this.
> 
> While you might be right, I don't think it is that big a cost to make 
> this support ARMv4 too.  In fact, if slow ARMv4 systems are still 
> routing packets out there, they are likely to see a huge benefit from 
> this.

This has also been addressed in v3.

Mircea
