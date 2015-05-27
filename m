From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] enable transparent LFS
Date: Wed, 27 May 2015 12:07:26 -0700
Message-ID: <20150527120726.65e9dd98@urahara>
References: <1432623090-2264-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:35003 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217AbbE0TH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 15:07:26 -0400
Received: by pdea3 with SMTP id a3so23395029pde.2
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 12:07:25 -0700 (PDT)
In-Reply-To: <1432623090-2264-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 May 2015 02:51:30 -0400
Mike Frysinger <vapier@gentoo.org> wrote:

> From: Mike Frysinger <vapier@chromium.org>
> 
> Make sure we use 64-bit filesystem functions everywhere.  This applies not
> only to being able to read large files (which generally doesn't apply to
> us), but also being able to simply stat them (as they might be using large
> inodes).
> 
> Signed-off-by: Mike Frysinger <vapier@chromium.org>
> ---
>  Makefile | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/Makefile b/Makefile
> index 35cacc4..9d35ef1 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -32,6 +32,8 @@ ADDLIB+=mpls_ntop.o mpls_pton.o
>  CC = gcc
>  HOSTCC = gcc
>  DEFINES += -D_GNU_SOURCE
> +# Turn on transparent support for LFS
> +DEFINES += -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE
>  CCOPTS = -O2
>  WFLAGS := -Wall -Wstrict-prototypes  -Wmissing-prototypes
>  WFLAGS += -Wmissing-declarations -Wold-style-definition -Wformat=2

I am okay with this, is something specific it fixes or is it just
general good practice?
