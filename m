From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Cleanup snmp6_alloc_dev()
Date: Wed, 17 Oct 2007 21:25:42 -0700 (PDT)
Message-ID: <20071017.212542.77405467.davem@davemloft.net>
References: <4715E79C.80306@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36732
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764264AbXJREZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 00:25:57 -0400
In-Reply-To: <4715E79C.80306@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 17 Oct 2007 14:44:44 +0400

> This functions is never called with NULL or not setup argument,
> so the checks inside are redundant.
> 
> Also, the return value is always -ENOMEM, so no need in 
> additional variable for this.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
