From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9][BNX2]: Introduce new bnx2_napi structure.
Date: Thu, 20 Dec 2007 19:56:44 -0800 (PST)
Message-ID: <20071220.195644.32304656.davem@davemloft.net>
References: <1198182704.9163.29.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53468
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753005AbXLUD4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 22:56:45 -0500
In-Reply-To: <1198182704.9163.29.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 20 Dec 2007 12:31:44 -0800

> [BNX2]: Introduce new bnx2_napi structure.
> 
> Introduce a bnx2_napi structure that will hold a napi_struct and
> other fields to handle NAPI polling for the napi_struct.  Various tx
> and rx indexes and status block pointers will be moved from the main
> bnx2 structure to this bnx2_napi structure.
> 
> Most NAPI path functions are modified to be passed this bnx2_napi
> struct pointer.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
