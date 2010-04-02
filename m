From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: remove redundant verification code
Date: Thu, 01 Apr 2010 18:44:32 -0700 (PDT)
Message-ID: <20100401.184432.78989436.davem@davemloft.net>
References: <1270083286-25332-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42598
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759118Ab0DBBob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 21:44:31 -0400
In-Reply-To: <1270083286-25332-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Thu,  1 Apr 2010 02:54:46 +0200

> The check if error signaling is wanted (inet->recverr != 0) is done by
> the caller: raw.c:raw_err() and udp.c:__udp4_lib_err(), so there is no
> need to check this condition again.
> 
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

Applied.
