From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2] iproute2: lib/utils.c bug fixes
Date: Sun, 14 Apr 2013 10:00:00 -0700
Message-ID: <20130414100000.3b73fa36@nehalam.linuxnetplumber.net>
References: <516AB8EE.5090901@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dash Four <mr.dash.four@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:40539 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752117Ab3DNRA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 13:00:27 -0400
Received: by mail-pd0-f176.google.com with SMTP id r11so2111568pdi.35
        for <netdev@vger.kernel.org>; Sun, 14 Apr 2013 10:00:26 -0700 (PDT)
In-Reply-To: <516AB8EE.5090901@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 14 Apr 2013 15:10:54 +0100
Dash Four <mr.dash.four@googlemail.com> wrote:

> This patch fixes the following 3 bugs in get_u32/get_u64 functions:
> 
>   1. On 32-bit systems, get_u32 could not detect an overflow.
>      get_u32(&l, "4294967296", 10) always returned 4294967295
>      (ULONG_MAX on 32-bit systems).
> 
>   2. get_u64(&ll, "4294967295", 10) was returning an error where
>      it shouldn't have (4294967295 is perfectly legitimate value for
>      unsigned long long).
> 
>   3. get_u64 couldn't detect an overflow errors (arg > ULLONG_MAX)
> 
> Changelog:
> 
> v2 - Dropped name title from Developer Certificate of Origin
> 
> Signed-off-by: Dash Four <mr.dash.four@googlemail.com>
> ---
>   lib/utils.c |    8 ++++++--
>   1 file changed, 6 insertions(+), 2 deletions(-)
> 

Thanks for your patch. there were lots of related over/underflow errors in
this code which have existed for a long time. I took your patch as motivation
and did multiple fixes to add error checking for all the cases present.

Thank you.
