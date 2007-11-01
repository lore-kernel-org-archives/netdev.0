From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/8] Auto-zero the allocated sock object
Date: Thu, 01 Nov 2007 00:35:00 -0700 (PDT)
Message-ID: <20071101.003500.51612292.davem@davemloft.net>
References: <472885B1.7090103@openvz.org>
	<472887CB.9050203@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55168
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753587AbXKAHfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 03:35:01 -0400
In-Reply-To: <472887CB.9050203@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 31 Oct 2007 16:48:59 +0300

> We have a __GFP_ZERO flag that allocates a zeroed chunk of memory.
> Use it in the sk_alloc() and avoid a hand-made memset().
> 
> This is a temporary patch that will help us in the nearest future :)
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
