From: David Miller <davem@davemloft.net>
Subject: Re: [2/4][BNX2]: Add delay before reading firmware version.
Date: Mon, 16 Jul 2007 18:26:55 -0700 (PDT)
Message-ID: <20070716.182655.88345213.davem@davemloft.net>
References: <1184616452.17688.19.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60550
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751781AbXGQB0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 21:26:53 -0400
In-Reply-To: <1184616452.17688.19.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 16 Jul 2007 13:07:32 -0700

> [BNX2]: Add delay before reading firmware version.
> 
> The management firmware may still be loading during bnx2_init_one()
> because of the D3hot -> D0 transition and the firmware version may
> not be available without waiting a bit.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
