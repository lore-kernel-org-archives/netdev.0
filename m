From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cnic: Shutdown iSCSI ring during uio_close.
Date: Tue, 22 Sep 2009 15:09:35 -0700 (PDT)
Message-ID: <20090922.150935.175171354.davem@davemloft.net>
References: <1253583577-8027-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michaelc@cs.wisc.edu, benli@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44049
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753135AbZIVWJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 18:09:16 -0400
In-Reply-To: <1253583577-8027-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 21 Sep 2009 18:39:37 -0700

> The iSCSI ring should be shutdown during uio_close instead of uio_open
> for proper operations.  This fixes the problem of the ring getting
> stuck intermittently.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied.
