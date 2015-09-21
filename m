From: Kalle Valo <kvalo@adurom.com>
Subject: Re: [PATCH 1/2 v2] airo: fix IW_AUTH_ALG_OPEN_SYSTEM
Date: Mon, 21 Sep 2015 14:39:28 +0300
Message-ID: <87d1xc2e8f.fsf@purkki.adurom.net>
References: <1442330289-2907-1-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from purkki.adurom.net ([80.68.90.206]:43225 "EHLO purkki.adurom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752476AbbIUMLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2015 08:11:32 -0400
In-Reply-To: <1442330289-2907-1-git-send-email-linux@rainbow-software.org>
	(Ondrej Zary's message of "Tue, 15 Sep 2015 17:18:08 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ondrej Zary <linux@rainbow-software.org> writes:

> IW_AUTH_ALG_OPEN_SYSTEM is ambiguous in set_auth for WEP as
> wpa_supplicant uses it for both no encryption and WEP open system.
> Cache the last mode set (only of these two) and use it here.
>
> This allows wpa_supplicant to work with unencrypted APs.
>
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> ---
>  drivers/net/wireless/airo.c |   33 ++++++++++++++++++++++++---------
>  1 file changed, 24 insertions(+), 9 deletions(-)

You should CC linux-wireless mailing list, otherwise patchwork won't see
it and I will miss your patch:

https://patchwork.kernel.org/project/linux-wireless/list/

-- 
Kalle Valo
