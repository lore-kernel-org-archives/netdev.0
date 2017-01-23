From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] [net-next] net: qcom/emac: rename emac_phy to
 emac_sgmii and move it
Date: Mon, 23 Jan 2017 12:55:02 -0500 (EST)
Message-ID: <20170123.125502.2263699912799183357.davem@redhat.com>
References: <1484954464-2622-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LinoSanfilippo@gmx.de
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44130 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750732AbdAWRzD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 12:55:03 -0500
In-Reply-To: <1484954464-2622-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Fri, 20 Jan 2017 17:21:03 -0600

> The EMAC has an internal PHY that is often called the "SGMII".  This
> SGMII is also connected to an external PHY, which is managed by phylib.
> These dual PHYs often cause confusion.  In this case, the data structure
> for managing the SGMII was mis-named and located in the wrong header file.
> 
> Structure emac_phy is renamed to emac_sgmii to clearly indicate it applies
> to the internal PHY only.  It also also moved from emac_phy.h (which
> supports the external PHY) to emac_sgmii.h (where it belongs).
> 
> To keep the changes minimal, only the structure name is changed, not
> the names of any variables of that type.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Applied, thanks.
