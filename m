From: David Miller <davem@davemloft.net>
Subject: Re: [UPDATED][NET-NEXT PATCH 1/4] bnx2: In bnx2_set_mac_link()
 return void rather then int
Date: Thu, 18 Sep 2008 16:38:48 -0700 (PDT)
Message-ID: <20080918.163848.194697920.davem@davemloft.net>
References: <20080918063933.GA8027@verge.net.au>
	<1221757033-4874-1-git-send-email-benli@broadcom.com>
	<1221757033-4874-2-git-send-email-benli@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: benli@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53741
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755018AbYIRXjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 19:39:01 -0400
In-Reply-To: <1221757033-4874-2-git-send-email-benli@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Benjamin Li" <benli@broadcom.com>
Date: Thu, 18 Sep 2008 09:57:10 -0700

> bnx2_set_mac_link() doesn't need to return any error codes.  And
> all the callers don't check the return code. It is safe to
> change the return type to a void.
> 
> Signed-off-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
