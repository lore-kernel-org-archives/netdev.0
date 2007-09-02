From: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: That whole "Linux stealing our code" thing
Date: Sun, 2 Sep 2007 03:55:37 +0200
Message-ID: <20070902015537.GH16016@stusta.de>
References: <200709010140.l811eq9H005896@cvs.openbsd.org> <f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com> <46D99FB7.6030505@garzik.org> <f34ca13c0709011037p221cb40fjf69651d1858df212@mail.gmail.com> <20070901205457.GK9260@stusta.de> <20070901215225.GM9260@stusta.de> <3A831845-B630-42AD-B52F-DC9EA2060BAE@dixongroup.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: mureninc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
To: Jason Dixon <jason-a0y0GdpcbPLlcHVOVdbKLw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <3A831845-B630-42AD-B52F-DC9EA2060BAE-a0y0GdpcbPLlcHVOVdbKLw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 01, 2007 at 08:36:24PM -0400, Jason Dixon wrote:
> On Sep 1, 2007, at 5:52 PM, Adrian Bunk wrote:
>
>> OK, I begin to understand this, there seem to be three different types
>> of files changed by Jiri's patch:
>> 1. dual licenced files planned to make GPL-only
>> 2. previously dual licenced files with a too recent version used planned
>>    to make GPL-only
>> 3. never dual licenced files planned to make GPL-only
>>
>> For files under 1. and 2. Reyk did contribute to dual licenced code
>> without touching the licence, but I missed that there's also code unter 3.
>>
>> So there is a problem, but not with the code under 1. (unless you plan
>> to change the semantics of the word "alternatively"), the problem is
>> with some headers under 2. plus the code under 3.
>
> The BSD license plainly states:
>
> "Permission to use, copy, modify, and/or distribute this software for any
> purpose with or without fee is hereby granted, provided that the above
> copyright notice and this permission notice appear in all copies."
>
> Once the grantor (Reyk) releases his code under that license, it must 
> remain.  You are free to derive work and redistribute under your license, 
> but the original copyright and license permission remains intact.  Many 
> other entities (Microsoft, Apple, Sun, etc) have used BSD code and have no 
> problem understanding this.  Why is this so difficult for the Linux brain 
> share to absorb?
>
> As a former Linux advocate and current OpenBSD user/developer, I'm appalled 
> that fellow open-source developers would see fit to cavalierly disregard 
> the rights of the original copyright holder.  You wield the GPL when it 
> suits you, and trample the courtesies of non-GPL developers just because 
> you [think you] can.  As bad as Jiri's offense was, it pales to the 
> impudence displayed by Alan Cox, one of the so-called defenders of free 
> software.
> 
> Shame on you all.

Jiri's patch would have wrongly not only removed the BSD statement from 
dual licenced files but also from not dual licenced files.

This was a mistake in this patch (that was never merged into the tree) 
neither Jiri nor Alan noticed.


The only disagreement is about the following:

Theo claimed boldly in the email that started this thread on 
linux-kernel it would "break the law" to choose one licence for dual 
licenced code like the following:


/*      $OpenBSD: ath.c,v 1.63 2007/05/09 16:41:14 reyk Exp $  */
/*      $NetBSD: ath.c,v 1.37 2004/08/18 21:59:39 dyoung Exp $        */

/*-
 * Copyright (c) 2002-2004 Sam Leffler, Errno Consulting
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer,
 *    without modification.
 * 2. Redistributions in binary form must reproduce at minimum a disclaimer
 *    similar to the "NO WARRANTY" disclaimer below ("Disclaimer") and any
 *    redistribution must be conditioned upon including a substantially
 *    similar Disclaimer requirement for further binary redistribution.
 * 3. Neither the names of the above-listed copyright holders nor the names
 *    of any contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * Alternatively, this software may be distributed under the terms of the
 * GNU General Public License ("GPL") version 2 as published by the Free
 * Software Foundation.
 *
 * NO WARRANTY
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF NONINFRINGEMENT, MERCHANTIBILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR SPECIAL, EXEMPLARY,
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
 * IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGES.
 */


> Jason Dixon

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
