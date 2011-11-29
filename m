From: David Miller <davem@davemloft.net>
Subject: Re: Subject: [PATCH 1/2] atm: br2684: Make headroom and
 hard_header_len depend on the payload type
Date: Tue, 29 Nov 2011 01:21:41 -0500 (EST)
Message-ID: <20111129.012141.1270567343227788762.davem@davemloft.net>
References: <201111281840.pASIeFhI011675@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451Ab1K2GXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 01:23:50 -0500
In-Reply-To: <201111281840.pASIeFhI011675@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Date: Mon, 28 Nov 2011 13:40:15 -0500

> 
> From: Pascal Hambourg <pascal@plouf.fr.eu.org>
> Date: Wed, 17 Aug 2011 08:37:18 +0200
> Subject: [PATCH 1/2] atm: br2684: Make headroom and hard_header_len depend on the payload type
> 
> Routed payload requires less headroom than bridged payload.
> So do not reallocate headroom if not needed.
> Also, add worst case AAL5 overhead to netdev->hard_header_len.
> 
> Signed-off-by: Pascal Hambourg <pascal@plouf.fr.eu.org>
> Signed-off-by: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

Applied.
