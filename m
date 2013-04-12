From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: lib/utils.c bug fixes
Date: Thu, 11 Apr 2013 20:06:56 -0700
Message-ID: <20130411200656.42dfb8bb@nehalam.linuxnetplumber.net>
References: <516771D5.3040607@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mr Dash Four <mr.dash.four@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:63355 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864Ab3DLDHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 23:07:18 -0400
Received: by mail-pd0-f175.google.com with SMTP id g10so1169072pdj.6
        for <netdev@vger.kernel.org>; Thu, 11 Apr 2013 20:07:18 -0700 (PDT)
In-Reply-To: <516771D5.3040607@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Apr 2013 03:30:45 +0100
Mr Dash Four <mr.dash.four@googlemail.com> wrote:

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
> Signed-off-by: Mr Dash Four <mr.dash.four@googlemail.com>

I don't demand Developer Certificate of Origin on iproute2 patches.
But if you are going to include it then you must use your real name,
no pseudonyms. See kernel/Documentation/SubmittingPatches.
