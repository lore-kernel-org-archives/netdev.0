From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] vlan: fix u64_stats
Date: Wed, 28 Jul 2010 16:41:07 +0800
Message-ID: <AANLkTimYEJvrydT=CpEu-0Crf==YijyfR6Sks=NiGEe=@mail.gmail.com>
References: <1280293833-8723-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:37764 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729Ab0G1Il2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 04:41:28 -0400
Received: by qyk8 with SMTP id 8so3364533qyk.19
        for <netdev@vger.kernel.org>; Wed, 28 Jul 2010 01:41:27 -0700 (PDT)
In-Reply-To: <1280293833-8723-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 28, 2010 at 1:10 PM, Changli Gao <xiaosuo@gmail.com> wrote:
> rx_stats->rx_errors should be under the protection of rx_stats->syncp.
>

I checked the code again. rx_errors is unsigned long, so need no
protection. Sorry for the noise.


-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
