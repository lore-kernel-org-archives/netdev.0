From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: [PATCH iproute2] Make builds default to quiet mode
Date: Tue, 24 May 2016 19:35:12 +0200
Message-ID: <87mvnfs6jz.fsf@linux-m68k.org>
References: <1464110858-30718-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:49641 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbcEXRfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 13:35:17 -0400
In-Reply-To: <1464110858-30718-1-git-send-email-dsa@cumulusnetworks.com>
	(David Ahern's message of "Tue, 24 May 2016 10:27:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsa@cumulusnetworks.com> writes:

> @@ -50,7 +54,7 @@ LDLIBS += $(LIBNETLINK)
>  all: Config
>  	@set -e; \
>  	for i in $(SUBDIRS); \
> -	do $(MAKE) $(MFLAGS) -C $$i; done
> +	do echo "\n$$i"; $(MAKE) $(MFLAGS) -C $$i; done

echo "\n" is not portable.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
