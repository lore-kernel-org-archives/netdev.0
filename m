From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tc35815: Enable NAPI
Date: Wed, 28 Oct 2009 03:57:43 -0700 (PDT)
Message-ID: <20091028.035743.76929614.davem@davemloft.net>
References: <1256564782-2781-2-git-send-email-anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf.roesch@rw-gmbh.de
To: anemo@mba.ocn.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50342
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751361AbZJ1K5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 06:57:22 -0400
In-Reply-To: <1256564782-2781-2-git-send-email-anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Date: Mon, 26 Oct 2009 22:46:22 +0900

> This driver has NAPI code but it has been disabled.  Enable it now.
> The non-napi code will be removed lator.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>

Applied.

Please remove the NAPI enabling macro and the tests for it.
NAPI support should be unconditional.

If people want to test the pre-NAPI behavior, they can check
out an older copy of the driver quite easily.

Thanks.
