From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] bridge: eliminate workqueue for carrier check
Date: Thu, 22 Feb 2007 01:10:41 -0800 (PST)
Message-ID: <20070222.011041.40575191.davem@davemloft.net>
References: <20070221224107.741532037@linux-foundation.org>
	<20070221224255.686055172@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@linux-foundation.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37587
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932862AbXBVJKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 04:10:42 -0500
In-Reply-To: <20070221224255.686055172@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 21 Feb 2007 14:41:09 -0800

> Having a work queue for checking carrier leads to lots of race issues.
> Simpler to just get the cost when data structure is created and
> update on change.
> 
> Signed-off-by: StephenHemminger <shemminger@linux-foundtion.org>

Applied, I guess the signoff typo is in your file :-)
