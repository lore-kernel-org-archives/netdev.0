From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cnic: Fix the type field in SPQ messages
Date: Thu, 06 Jan 2011 11:27:32 -0800 (PST)
Message-ID: <20110106.112732.260093640.davem@davemloft.net>
References: <1294276453-5957-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51176
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752894Ab1AFT1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 14:27:00 -0500
In-Reply-To: <1294276453-5957-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 5 Jan 2011 17:14:13 -0800

> The new firmware interface requires each Slow Path Queue (SPQ) message's
> type field to include the function number.  The existing code does not
> do this consistently.  We fix this by OR'ing in the function number
> into the type field centrally in cnic_submit_kwqe_16().
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thank you.
