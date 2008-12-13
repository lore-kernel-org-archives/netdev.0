From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/33] sfc: Make reset_workqueue driver-global rather
 than per-NIC
Date: Fri, 12 Dec 2008 21:33:11 -0800 (PST)
Message-ID: <20081212.213311.241270982.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212125037.GF10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58423
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753282AbYLMFdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:33:10 -0500
In-Reply-To: <20081212125037.GF10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:50:38 +0000

> From: Steve Hodgson <shodgson@solarflare.com>
> 
> Each reset is serialised by the rtnl_lock anyway, so there's no win
> per-NIC.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
