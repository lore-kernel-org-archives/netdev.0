From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: don't stop queue on shutdown
Date: Tue, 22 Jul 2008 21:53:55 -0700 (PDT)
Message-ID: <20080722.215355.103433572.davem@davemloft.net>
References: <20080722215042.310ef2f3@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37050
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752473AbYGWExz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 00:53:55 -0400
In-Reply-To: <20080722215042.310ef2f3@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 22 Jul 2008 21:50:42 -0700

> It is unnecessary, to stop queue and turn off carrier in shutdown
> routine. With new netdev_queue this causes warnings.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Stephen.
