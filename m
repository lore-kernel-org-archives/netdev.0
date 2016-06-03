From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 04/17] net: dsa: tag_{e}dsa.c: Remove dependency
 on platform data
Date: Fri, 3 Jun 2016 10:16:45 -0700
Message-ID: <5751BB7D.70801@gmail.com>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
 <1464972256-10408-5-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:32996 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932505AbcFCRQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 13:16:48 -0400
Received: by mail-pa0-f52.google.com with SMTP id ec8so10346117pac.0
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 10:16:48 -0700 (PDT)
In-Reply-To: <1464972256-10408-5-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2016 09:44 AM, Andrew Lunn wrote:
> The platform data nr_chips is used when validating a received packet,
> to ensure it comes from a know switch chip. The number of possible
> switches is limited to DSA_MAX_SWITCHES, so use this as the first
> validation step. The new binding allows holes in the dst->ds[] array,
> so also ensure ensure there is a valid dsa_switch for this packet.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
