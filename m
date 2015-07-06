From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH V2] cdc_ncm: Add support for moving NDP to end of NCM
 frame
Date: Mon, 06 Jul 2015 12:08:16 +0200
Message-ID: <1436177296.8225.25.camel@suse.com>
References: <1435787748-30393-1-git-send-email-mrkiko.rs@gmail.com>
	 <alpine.LNX.2.20.1507051219280.12595@archiso.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:32770 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754021AbbGFKJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2015 06:09:18 -0400
In-Reply-To: <alpine.LNX.2.20.1507051219280.12595@archiso.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-07-05 at 12:21 +0200, Enrico Mioso wrote:
> When sending lots of small packets, this patch will generate an "Unable to 
> handle kernel paging request" in the memset call:
> ndp16 = memset(ctx->delayed_ndp16, 0, ctx->max_ndp_size);
> And I don't know why.
> Any comment or suggestion would be greatly apreciated.
> This has been reproduced in a QEMU X86 VM, from kernel 4.0.4 to current git.

I cannot see how this can fail and the preceding copy work.
Can you post the full message?

	Regards
		Oliver
