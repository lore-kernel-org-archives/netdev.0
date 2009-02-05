From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.29 1/2] gianfar: Fix BD_LENGTH_MASK definition
Date: Wed, 04 Feb 2009 16:38:14 -0800 (PST)
Message-ID: <20090204.163814.151001445.davem@davemloft.net>
References: <1233710223-17808-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52632
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761132AbZBEAiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 19:38:17 -0500
In-Reply-To: <1233710223-17808-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Tue,  3 Feb 2009 19:16:59 -0600

> BD_LENGTH_MASK is supposed to catch the low 16-bits of the status field, not
> the low byte.  The old way, we would never be able to clean up tx packets with
> sizes divisible by 256.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Applied.
