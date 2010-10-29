From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] net: Limit socket I/O iovec total length to INT_MAX.
Date: Fri, 29 Oct 2010 12:37:29 -0700
Message-ID: <AANLkTikGkfcHdemZwURrYLPBC1QQnbQP_g-7YadzeE-D@mail.gmail.com>
References: <1288360820.2092.34.camel@dan> <AANLkTikeaXncdUohUiGF2EkhujYETK5dtyOJASffz2qR@mail.gmail.com>
 <AANLkTi=sUDRzGnkp57OCQUi9APHWLYLShhiTVHLyq1eV@mail.gmail.com> <20101029.123230.226768623.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: viro@zeniv.linux.org.uk, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, allan.stephens@windriver.com,
	drosenberg@vsecurity.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41471 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751953Ab0J2Thv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 15:37:51 -0400
Received: from mail-iw0-f174.google.com (mail-iw0-f174.google.com [209.85.214.174])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id o9TJboxP016279
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 12:37:50 -0700
Received: by iwn10 with SMTP id 10so4165479iwn.19
        for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 12:37:50 -0700 (PDT)
In-Reply-To: <20101029.123230.226768623.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 29, 2010 at 12:32 PM, David Miller <davem@davemloft.net> wrote:
>
> I just got out of a long dentist appointment, will look at this right
> now, thanks!

I booted with it and committed it as "obvious". Let's see if there is
any fallout. I doubt it, but I also doubt we'll find any until we have
lots of testers, unless I made some subtly totally buggy change that
just didn't happen to show up during a normal boot.

                      Linus
