From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [bnx2]: Fix problem of using wrong IRQ handler.
Date: Wed, 18 Mar 2009 18:12:00 -0700 (PDT)
Message-ID: <20090318.181200.129327163.davem@davemloft.net>
References: <1237420377-4444-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37525
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751383AbZCSBMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 21:12:13 -0400
In-Reply-To: <1237420377-4444-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 18 Mar 2009 15:52:57 -0800

> The MSI-X handler was chosen before the call to pci_enable_msix().
> If MSI-X was not available, the wrong MSI-X handler would be used in
> INTA mode.  This would cause a screaming interrupt problem because
> INTA would not be cleared by the MSI-X handler.
> 
> Fixed by assigning MSI-X handler after pci_enable_msix() returns
> successfully.  Also update version to 1.9.3.
> 
> Thomas Chenault <thomas_chenault@dell.com> helped us find this problem.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
