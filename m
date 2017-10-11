From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3] lib: fix multiple strlcpy definition
Date: Wed, 11 Oct 2017 11:03:35 -0700
Message-ID: <20171011110335.1e2a793c@xeon-e3>
References: <9a00dc2dca0650efd7e169db9bb15ae1ec043c08.1507528184.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:50811 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757798AbdJKSDh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 14:03:37 -0400
Received: by mail-pf0-f178.google.com with SMTP id m63so1495925pfk.7
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 11:03:37 -0700 (PDT)
In-Reply-To: <9a00dc2dca0650efd7e169db9bb15ae1ec043c08.1507528184.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  9 Oct 2017 08:49:44 +0300
Baruch Siach <baruch@tkos.co.il> wrote:

> Some C libraries, like uClibc and musl, provide BSD compatible
> strlcpy(). Add check_strlcpy() to configure, and avoid defining strlcpy
> and strlcat when the C library provides them.
> 
> This fixes the following static link error with uClibc-ng:
> 
> .../sysroot/usr/lib/libc.a(strlcpy.os): In function `strlcpy':
> strlcpy.c:(.text+0x0): multiple definition of `strlcpy'
> ../lib/libutil.a(utils.o):utils.c:(.text+0x1ddc): first defined here
> collect2: error: ld returned 1 exit status
> 
> Acked-by: Phil Sutter <phil@nwl.cc>
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>

Thanks for fixing. Most people never use other versions of libc
so things get broken rather often.
