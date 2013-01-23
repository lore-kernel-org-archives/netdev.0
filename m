From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] IP_GRE: Fix kernel panic in IP_GRE with GRE csum.
Date: Wed, 23 Jan 2013 14:00:13 -0800
Message-ID: <1358978413.12374.1114.camel@edumazet-glaptop>
References: <1358977542-1627-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:33352 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab3AWWAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 17:00:16 -0500
Received: by mail-pb0-f42.google.com with SMTP id rp2so4942951pbb.15
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 14:00:15 -0800 (PST)
In-Reply-To: <1358977542-1627-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 13:45 -0800, Pravin B Shelar wrote:
> Due to IP_GRE GSO support, GRE can recieve non linear skb which
> results in panic in case of GRE_CSUM.
> Following patch fixes it by using correct csum API.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
> v3: Coding style Fix.

More precisely, this comes from SG (Scatter Gather) support, not GSO.

Bug introduced in commit 6b78f16e4bdde3936b
(gre: add GSO support)

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
