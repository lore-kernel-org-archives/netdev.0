From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3][NETLABEL]: Compilation for CONFIG_AUDIT=n case.
Date: Tue, 12 Feb 2008 22:35:44 -0800 (PST)
Message-ID: <20080212.223544.21007139.davem@davemloft.net>
References: <47AB3DDE.8050109@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53361
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752886AbYBMGfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 01:35:12 -0500
In-Reply-To: <47AB3DDE.8050109@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 07 Feb 2008 20:20:30 +0300

> The audit_log_start() will expand into an empty do { } while (0)
> construction and the audit_ctx becomes unused.
> 
> The solution: push current->audit_context into audit_log_start()
> directly, since it is not required in any other place in the 
> calling function.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
