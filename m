From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix tcp header size miscalculation when window
 scale is unused (resend)
Date: Wed, 27 Aug 2008 02:34:22 -0700 (PDT)
Message-ID: <20080827.023422.104292029.davem@davemloft.net>
References: <200808261656.m7QGuR5k029805@mailhub.lss.emc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: love_phil@emc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44906
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753426AbYH0Je1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 05:34:27 -0400
In-Reply-To: <200808261656.m7QGuR5k029805@mailhub.lss.emc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: love_phil@emc.com
Date: Tue, 26 Aug 2008 12:56:27 -0400 (EDT)

> tcp: fix tcp header size miscalculation when window scale is unused
> 
> The size of the TCP header is miscalculated when the window scale ends up being 0. Additionally, this can be induced by sending a SYN to a passive open port with a window scale option with value 0.
> 
> Signed-off-by: Philip Love <love_phil@emc.com>

Patch applied, thanks for being persistent and getting your email
patch submissions working properly.
