From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] b44: add 64 bit stats
Date: Wed, 18 Jul 2012 05:50:02 +0200
Message-ID: <1342583402.2626.1376.camel@edumazet-glaptop>
References: <20120716.230806.242760837075045729.davem@davemloft.net>
	 <1342583161-1184-1-git-send-email-kgroeneveld@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin Groeneveld <kgroeneveld@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:56892 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463Ab2GRDuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 23:50:06 -0400
Received: by vcbfk26 with SMTP id fk26so802000vcb.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 20:50:06 -0700 (PDT)
In-Reply-To: <1342583161-1184-1-git-send-email-kgroeneveld@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-17 at 23:46 -0400, Kevin Groeneveld wrote:
> From: Kevin Groeneveld <kgroeneveld@gmail.com>
> 
> Add support for 64 bit stats to Broadcom b44 ethernet driver.
> 
> Signed-off-by: Kevin Groeneveld <kgroeneveld@gmail.com>
> ---
> v2: use u64_stats_fetch_begin_bh/u64_stats_fetch_retry_bh instead of
>     u64_stats_fetch_begin/u64_stats_fetch_retry as stats update happens in a
>     timer interrupt

Seems good this time, thanks

Signed-off-by: Eric Dumazet <edumazet@google.com>
