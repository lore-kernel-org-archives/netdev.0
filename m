From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 14/19] sky2: remove unnecessary reads of PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 11:55:09 -0700
Message-ID: <20110627115509.44f3f16a@nehalam.ftrdhcpuser.net>
References: <1309196816-16198-1-git-send-email-jdmason@kudzu.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jon Mason <jdmason@kudzu.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:32818 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753550Ab1F0SzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 14:55:15 -0400
In-Reply-To: <1309196816-16198-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Jun 2011 12:46:56 -0500
Jon Mason <jdmason@kudzu.us> wrote:

> The PCIE capability offset is saved during PCI bus walking.  It will
> remove an unnecessary search in the PCI configuration space if this
> value is referenced instead of reacquiring it.  Also, pci_is_pcie is a
> better way of determining if the device is PCIE or not (as it uses the
> same saved PCIE capability offset).
> 
> Signed-off-by: Jon Mason <jdmason@kudzu.us>

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
