From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ppp: add 64 bit stats
Date: Sat, 28 Jul 2012 09:39:01 +0200
Message-ID: <1343461141.2626.13122.camel@edumazet-glaptop>
References: <1343446733-4791-1-git-send-email-kgroeneveld@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin Groeneveld <kgroeneveld@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:55763 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536Ab2G1HjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2012 03:39:07 -0400
Received: by wgbdr13 with SMTP id dr13so3390593wgb.1
        for <netdev@vger.kernel.org>; Sat, 28 Jul 2012 00:39:05 -0700 (PDT)
In-Reply-To: <1343446733-4791-1-git-send-email-kgroeneveld@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-27 at 23:38 -0400, Kevin Groeneveld wrote:
> Add 64 bit stats to ppp driver.  The 64 bit stats include tx_bytes,
> rx_bytes, tx_packets and rx_packets.  Other stats are still 32 bit.
> The 64 bit stats can be retrieved via the ndo_get_stats operation.  The
> SIOCGPPPSTATS ioctl is still 32 bit stats only.
> 
> Signed-off-by: Kevin Groeneveld <kgroeneveld@gmail.com>
> ---
> v2: - do not use percpu variables for stats
>     - use ppp_recv_lock/ppp_xmit_lock when reading 64 bit stats
> 

Seems fine to me this time ;)

Acked-by: Eric Dumazet <edumazet@google.com>
