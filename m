From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cnic: Fix parity error code conflict
Date: Wed, 21 Mar 2012 21:58:52 -0400 (EDT)
Message-ID: <20120321.215852.456491443371085182.davem@davemloft.net>
References: <1332380314-14198-1-git-send-email-mchan@broadcom.com>
	<1332380314-14198-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48681 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964833Ab2CVB64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 21:58:56 -0400
In-Reply-To: <1332380314-14198-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 21 Mar 2012 17:38:34 -0800

> The recently added parity error handling used an error code that was
> already defined for a different error.  This could lead to bnx2x
> firmware assert.  We need to fix this with new error codes that are
> defined for parity error only.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Reviewed-by: Eddie Wai <eddie.wai@broadcom.com>
> Reviewed-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>

Applied.
