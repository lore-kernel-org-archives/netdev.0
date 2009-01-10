From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] forcedeth: xmit lock fix
Date: Fri, 09 Jan 2009 23:13:31 -0800 (PST)
Message-ID: <20090109.231331.168136341.davem@davemloft.net>
References: <4967BBB0.90809@nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, jgarzik@pobox.com, akpm@osdl.org,
	netdev@vger.kernel.org
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58656
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751950AbZAJHNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 02:13:30 -0500
In-Reply-To: <4967BBB0.90809@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <aabdulla@nvidia.com>
Date: Fri, 09 Jan 2009 16:03:44 -0500

> This patch fixes a potential race condition between xmit thread and xmit completion thread. The calculation of empty tx descriptors is not performed under the lock. This could cause it to set the stop flag while the completion thread finishes all tx's. This will result in the tx queue in stopped state and no one to wake it up.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

Applied.
