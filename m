From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25 2/4][BNX2]: Fix minor bug in bnx2_has_work().
Date: Mon, 21 Jan 2008 17:06:49 -0800 (PST)
Message-ID: <20080121.170649.134552864.davem@davemloft.net>
References: <1200964081.10010.47.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55108
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752714AbYAVBGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 20:06:42 -0500
In-Reply-To: <1200964081.10010.47.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 21 Jan 2008 17:08:01 -0800

> [BNX2]: Fix minor bug in bnx2_has_work().
> 
> It is more correct to get the status block from the bnx2_napi struct
> instead of the bnx2 struct.  It happens that they are the same in this
> case because we are using the first MSIX vector.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
