From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 2/2] ip: Harmonise usage references to show /
 list option
Date: Tue, 24 Mar 2015 14:53:15 -0700
Message-ID: <20150324145315.754c6ff3@urahara>
References: <1426499950-6641-1-git-send-email-mark.einon@gmail.com>
	<1426499950-6641-2-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mark Einon <mark.einon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34094 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883AbbCXVxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 17:53:12 -0400
Received: by pdbni2 with SMTP id ni2so6340591pdb.1
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 14:53:12 -0700 (PDT)
In-Reply-To: <1426499950-6641-2-git-send-email-mark.einon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Mar 2015 09:59:10 +0000
Mark Einon <mark.einon@gmail.com> wrote:

> diff --git a/ip/iproute.c b/ip/iproute.c
> index c842e85..b863e7b 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -59,7 +59,7 @@ static void usage(void) __attribute__((noreturn));
>  
>  static void usage(void)
>  {
> -	fprintf(stderr, "Usage: ip route { list | flush } SELECTOR\n");

Sorry, this sounds like a good idea until I went and checked what
is shown on the man pages.

The ip route man page has:

       ip route { list | flush } SELECTOR

For me, it is more important that the usage match the man page,
rather than having all usage messages match.
