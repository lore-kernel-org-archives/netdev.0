From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] realtek: convert to per-chip mask
Date: Tue, 23 Jul 2013 18:56:52 +0100
Message-ID: <1374602212.2072.1.camel@bwh-desktop.uk.level5networks.com>
References: <3162188.mmLmSZRt9A@al> <6657153.nK7z8HGonh@al>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:21813 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933657Ab3GWR45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 13:56:57 -0400
In-Reply-To: <6657153.nK7z8HGonh@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-23 at 10:51 +0200, Peter Wu wrote:
> The previous HW_REVID macro did not make identifiers more readable
> (compared to hex values like 0x12345678) and only allowed for one static
> mask. To make it easier to update the chips list, let's use similar
> structures as r8169 and remove HW_REVID.
> 
> Names are removed and separated from the table and separated because the
> mac_version does not have to be unique.
> 
> There are no functional changes for the output, except that the output
> now mentions "TxConfig" instead of "mask" when a chip is not found.
> Since the mask can be anything, the word is not masked either.
> 
> Signed-off-by: Peter Wu <lekensteyn@gmail.com>
> ---
>  realtek.c | 106 
> ++++++++++++++++++++++++++++++++++++--------------------------
>  1 file changed, 62 insertions(+), 44 deletions(-)
[...]

This patch has been corrupted by your mailer (specifically, it has been
word-wrapped).  See Documentation/email-clients.txt in the Linux source
tree.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
