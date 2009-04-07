From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibm_newemac: Fix dangerous struct assumption
Date: Mon, 06 Apr 2009 17:43:24 -0700 (PDT)
Message-ID: <20090406.174324.254969238.davem@davemloft.net>
References: <20090406142710.2d091038@hyperion.delvare>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jwboyer@linux.vnet.ibm.com,
	jgarzik@pobox.com
To: khali@linux-fr.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46984
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752122AbZDGAne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 20:43:34 -0400
In-Reply-To: <20090406142710.2d091038@hyperion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <khali@linux-fr.org>
Date: Mon, 6 Apr 2009 14:27:10 +0200

> The ibm_newemac driver includes code which assumes that the
> work_struct which is included in every delayed_work is the first
> member of that structure. This is currently the case but might change
> in the future, so use to_delayed_work() instead, which doesn't make
> such an assumption.
> 
> Signed-off-by: Jean Delvare <khali@linux-fr.org>

Applied.
