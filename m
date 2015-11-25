From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] isdn: Partially revert debug format string usage
 clean up
Date: Wed, 25 Nov 2015 11:50:10 -0500 (EST)
Message-ID: <20151125.115010.1628961628426020285.davem@davemloft.net>
References: <1448433910@msgid.manchmal.in-ulm.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, isdn@linux-pingi.de, keescook@chromium.org
To: linux-kernel.bfrz@manchmal.in-ulm.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751699AbbKYQuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 11:50:12 -0500
In-Reply-To: <1448433910@msgid.manchmal.in-ulm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>
Date: Wed, 25 Nov 2015 07:47:40 +0100

> Commit 35a4a57 ("isdn: clean up debug format string usage") introduced
> a safeguard to avoid accidential format string interpolation of data
> when calling debugl1 or HiSax_putstatus. This did however not take into
> account VHiSax_putstatus (called by HiSax_putstatus) does *not* call
> vsprintf if the head parameter is NULL - the format string is treated
> as plain text then instead. As a result, the string "%s" is processed
> literally, and the actual information is lost. This affects the isdnlog
> userspace program which stopped logging information since that commit.
> 
> So revert the HiSax_putstatus invocations to the previous state.
> 
> Fixes: 35a4a5733b0a ("isdn: clean up debug format string usage")
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Karsten Keil <isdn@linux-pingi.de>
> Signed-off-by: Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>

Applied, thanks.
