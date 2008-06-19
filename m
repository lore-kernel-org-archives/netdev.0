From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8] bnx2: Turn on multi rx rings.
Date: Thu, 19 Jun 2008 16:43:48 -0700 (PDT)
Message-ID: <20080619.164348.195675064.davem@davemloft.net>
References: <1213835132-5698-1-git-send-email-mchan@broadcom.com>
	<1213835132-5698-7-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48796
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751559AbYFSXnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 19:43:49 -0400
In-Reply-To: <1213835132-5698-7-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 18 Jun 2008 17:25:30 -0700

> Enable multiple rx rings if MSI-X vectors are available.  We enable
> up to 7 rx rings.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied to net-next-2.6

I hope that on the TX side you'll use some power-of-2
number of TX rings as this will make the SW flow hash
function less expensive to compute.
