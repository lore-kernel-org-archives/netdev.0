From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: fix error in rx completion processing.
Date: Fri, 11 Dec 2009 22:59:17 -0800 (PST)
Message-ID: <20091211.225917.28794779.davem@davemloft.net>
References: <20091212013847.GA10922@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42118
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750699AbZLLG7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2009 01:59:11 -0500
In-Reply-To: <20091212013847.GA10922@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Sat, 12 Dec 2009 07:08:49 +0530

> There are certain skews of the NIC which have multiple bits set in adapter->cap.
> Use & instead of == to process rx completions.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
