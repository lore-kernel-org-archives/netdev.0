From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [Linux-zigbee-devel] ieee802154: WARNING: at
 mm/page_alloc.c:2095
Date: Thu, 15 Dec 2011 16:13:28 +0200
Message-ID: <1323958408.3992.20.camel@lappy>
References: <1321948410.3787.3.camel@lappy>
	 <CAJmB2rCa-tODD9vFBRRY+Qp3DKDJN6VBLurE=TEqPatGFJEH4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dbaryshkov@gmail.com, slapin@ossfans.org,
	davem <davem@davemloft.net>, netdev <netdev@vger.kernel.org>,
	linux-zigbee-devel@lists.sourceforge.net
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42217 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751282Ab1LOONe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 09:13:34 -0500
Received: by wgbdr13 with SMTP id dr13so4140415wgb.1
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2011 06:13:33 -0800 (PST)
In-Reply-To: <CAJmB2rCa-tODD9vFBRRY+Qp3DKDJN6VBLurE=TEqPatGFJEH4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-12-15 at 15:21 +0300, Alexander Smirnov wrote:
> first of all could you please specify:
> 1. What's the kernel do you use?

linux-next.

> 2. What's the config options are enabled in your kernel?

It's a testing kernel which is pretty close to being 'make
allyesconfig'. So if you're thinking about a specific feature - it's
probably '=y'.

> 3. What the HW do you use and what is the use case?

I actually don't have any special HW, this was part of a fuzzer test.

> 4. What you do to represent this error? 

According to the fuzzer it's the result of calling sys_sendto() with a
pretty large numbrt in the length field.

-- 

Sasha.
