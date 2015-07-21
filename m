From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [2/2] iwlegacy: convert hex_dump_to_buffer() to %*ph
Date: Tue, 21 Jul 2015 15:08:52 +0000 (UTC)
Message-ID: <20150721150852.6A966141BD5@smtp.codeaurora.org>
References: <1437050535-22858-2-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:39193 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932312AbbGUPIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 11:08:53 -0400
In-Reply-To: <1437050535-22858-2-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> There is no need to use hex_dump_to_buffer() in the cases like this:
> 
> 	hexdump_to_buffer(buf, len, 16, 1, outbuf, outlen, false);	/* len <= 16 */
> 	sprintf("%s\n", outbuf);
> 
> since it maybe easily converted to simple:
> 
> 	sprintf("%*ph\n", len, buf);
> 
> Note: it seems in the case the output is groupped by 2 bytes and looks like a
> typo. Thus, patch changes that to plain byte stream.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
