From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cnic: Fix context memory init. on 5709.
Date: Thu, 27 May 2010 16:31:51 -0700 (PDT)
Message-ID: <20100527.163151.260106183.davem@davemloft.net>
References: <1274991858-6201-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45083
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932243Ab0E0Xbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 19:31:41 -0400
In-Reply-To: <1274991858-6201-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 27 May 2010 13:24:18 -0700

> We need to zero context memory on 5709 in the function cnic_init_context().
> Without this, iscsid restart on 5709 will not work because of stale data.
> TX context blocks should not be initialized by cnic_init_context() because
> of the special remapping on 5709.
> 
> Update version to 2.1.2.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.
