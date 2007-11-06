From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -net 2/2] Put proc_net_create() on death row
Date: Tue, 06 Nov 2007 05:28:23 -0800 (PST)
Message-ID: <20071106.052823.160483403.davem@davemloft.net>
References: <20071106122350.GB6215@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devel@openvz.org
To: adobriyan@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49141
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751112AbXKFN2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 08:28:24 -0500
In-Reply-To: <20071106122350.GB6215@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@sw.ru>
Date: Tue, 6 Nov 2007 15:23:50 +0300

> proc_net_create() stands on the way of shrinking the number of
> interfaces one can use for /proc files, namely, it uses ->get_info
> hook which will be converted, deprecated and deleted on its own
> schedule.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>

Applied.
