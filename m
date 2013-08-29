From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] realtek: convert to per-chip mask
Date: Thu, 29 Aug 2013 21:51:41 +0100
Message-ID: <1377809501.5372.17.camel@bwh-desktop.uk.level5networks.com>
References: <1376429119-31380-1-git-send-email-lekensteyn@gmail.com>
	 <1376429119-31380-2-git-send-email-lekensteyn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Francois Romieu <romieu@fr.zoreil.com>
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30944 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755430Ab3H2Uvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 16:51:44 -0400
In-Reply-To: <1376429119-31380-2-git-send-email-lekensteyn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-13 at 23:25 +0200, Peter Wu wrote:
> The previous HW_REVID macro did not make identifiers more readable
> (compared to hex values like 0x12345678) and only allowed for one static
> mask. To make it easier to update the chips list, let's use similar
> structures as r8169 and remove HW_REVID.
> 
> Names are removed and separated from the table and separated because the
> mac_version does not have to be unique.
> 
> While at it, change "RTL-xxxx" to "RTLxxxx" to match the names of
> Realtek and r8169 driver. Besides that, the only output change is when
> a chip is not recognized in which case "TxConfig" is now mentioned
> instead of "mask". Since the mask can be anything, the displayed word is
> not masked either.
> 
> Signed-off-by: Peter Wu <lekensteyn@gmail.com>
[...]

Applied, thanks.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
