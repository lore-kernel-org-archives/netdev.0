From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [SCTP] Unmap v4mapped addresses during
 SCTP_BINDX_REM_ADDR operation.
Date: Tue, 17 Apr 2007 12:53:44 -0700 (PDT)
Message-ID: <20070417.125344.41948535.davem@davemloft.net>
References: <11762400848-git-send-email-vladislav.yasevich@hp.com>
	<11762400843295-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgaltieri@mvista.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57573
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161140AbXDQTxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 15:53:42 -0400
In-Reply-To: <11762400843295-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Tue, 10 Apr 2007 17:21:24 -0400

> From: Paolo Galtieri <pgaltieri@mvista.com>
> 
> During the sctp_bindx() call to add additional addresses to the
> endpoint, any v4mapped addresses are converted and stored as regular
> v4 addresses.  However, when trying to remove these addresses, the
> v4mapped addresses are not converted and the operation fails.  This
> patch unmaps the addresses on during the remove operation as well.
> 
> Signed-off-by: Paolo Galtieri <pgaltieri@mvista.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Patch applied, thank you.
