From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NET-2.6.25][IPV6] fix section mismatch warnings
Date: Thu, 13 Dec 2007 05:35:10 -0800 (PST)
Message-ID: <20071213.053510.237730064.davem@davemloft.net>
References: <47610BDE.9040907@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58626
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752577AbXLMNfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 08:35:11 -0500
In-Reply-To: <47610BDE.9040907@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Thu, 13 Dec 2007 11:39:26 +0100

> Removed useless and buggy __exit section in the different 
> ipv6 subsystems. Otherwise they will be called inside an
> init section during rollbacking in case of an error in the
> protocol initialization.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied, thanks.
