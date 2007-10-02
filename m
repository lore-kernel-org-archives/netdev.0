From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.24 2/3][BNX2]: Optimize firmware loading.
Date: Tue, 02 Oct 2007 16:27:54 -0700 (PDT)
Message-ID: <20071002.162754.63483316.davem@davemloft.net>
References: <1191371023.5961.32.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vda.linux@googlemail.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38494
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753270AbXJBX1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 19:27:54 -0400
In-Reply-To: <1191371023.5961.32.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 02 Oct 2007 17:23:43 -0700

> [BNX2]: Optimize firmware loading.
> 
> This is a follow up to the patches from Denys Vlasenkos
> <vda.linux@googlemail.com> to further optimize firmware loading.
> 
> 1. In bnx2_init_cpus(), we allocate memory for decompression once
> and use it repeatedly instead of doing this for every firmware image.
> 
> 2. We eliminate the BSS and SBSS firmware sections in bnx2_fw*.h since
> these are always zeros.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks for following up on this Michael.
