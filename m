From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Kernel 4.1.12 crash
Date: Sat, 21 Nov 2015 21:17:41 -0800
Message-ID: <56514FF5.7060906@gmail.com>
References: <564F26FF.3040605@seti.kr.ua> <564FA904.7020603@gmail.com>
 <5650287B.9070901@seti.kr.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Andrew <nitr0@seti.kr.ua>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34811 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763AbbKVFRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 00:17:45 -0500
Received: by padhx2 with SMTP id hx2so157857137pad.1
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2015 21:17:45 -0800 (PST)
In-Reply-To: <5650287B.9070901@seti.kr.ua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2015 12:16 AM, Andrew wrote:
> Memory corruption, if happens, IMHO shouldn't be a hardware-related - 
> almost all of these boxes, except H61M-based box from 1st log, works 
> for a long time with uptime more than year; and only software was 
> changed on it; H61M-based box runs memtest86 for a tens of hours w/o 
> any error. If it was caused by hardware - they should crash even earlier.

I wasn't saying it was hardware related.  My thought is that it could be 
some sort of use after free or double free type issue. Basically what 
you end up with is the memory getting corrupted by software that is 
accessing regions it shouldn't be.

> Rarely on different servers I saw 'zram decompression error' messages 
> (in this case I've got such message on H61M-based box).
>
> Also, other people that uses accel-ppp as BRAS software, have 
> different kernel panics/bugs/oopses on fresh kernels.
>
> I'll try to apply these patches, and I'll try to switch back to 
> kernels that were stable on some boxes.

If you could bisect this it would be useful.  Basically we just need to 
determine where in the git history these issues started popping up so 
that we can then narrow down on the root cause.

- Alex
