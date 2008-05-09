From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] [TIPC]: Increase buffer headroom to support
 gianfar
Date: Thu, 08 May 2008 17:15:04 -0700 (PDT)
Message-ID: <20080508.171504.143648405.davem@davemloft.net>
References: <1210291675-5234-1-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42903
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755255AbYEIAPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 20:15:10 -0400
In-Reply-To: <1210291675-5234-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Thu,  8 May 2008 20:07:55 -0400

> This patch increases the headroom TIPC reserves in each sk_buff
> to 24 bytes, due to the 8 byte FCB used by gianfar.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

This is not how this is computed.

Please use LL_RESERVED_SPACE() like every other packet output
path does.  Or, at a minimum, reserve LL_MAX_HEADER bytes.
