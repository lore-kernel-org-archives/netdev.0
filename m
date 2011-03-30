From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] via-ircc: Use pci_{get,set}_drvdata() instead of
 static pointer variable
Date: Wed, 30 Mar 2011 00:13:04 -0700 (PDT)
Message-ID: <20110330.001304.212682079.davem@davemloft.net>
References: <1301368243.26693.751.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrewb@bgc.com.au, samuel@sortiz.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42432
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752789Ab1C3HNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 03:13:42 -0400
In-Reply-To: <1301368243.26693.751.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Tue, 29 Mar 2011 04:10:43 +0100

> via-ircc still maintains its own array of device pointers in Linux 2.4
> style.  Worse, it always uses index 0, so it will crash if there are
> multiple suitable devices in the system.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied.
