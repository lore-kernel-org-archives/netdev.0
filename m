From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: fix uninitialized error return
Date: Mon, 25 Apr 2016 21:24:34 -0400
Message-ID: <87wpnlmab1.fsf@ketchup.mtl.sfl>
References: <1461622282-30463-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Colin King <colin.king@canonical.com>,
	"David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34082 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995AbcDZBYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 21:24:38 -0400
In-Reply-To: <1461622282-30463-1-git-send-email-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Colin,

Colin King <colin.king@canonical.com> writes:

> From: Colin Ian King <colin.king@canonical.com>
>
> The error return err is not initialized and there is a possibility
> that err is not assigned causing mv88e6xxx_port_bridge_join to
> return a garbage error return status. Fix this by initializing err
> to 0.
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Even though that cannot happen, the fix doesn't hurt.
Adding Geert in the loop who submitted an RFC for this first:

    https://lkml.org/lkml/2016/4/25/95

Thanks,

        Vivien
