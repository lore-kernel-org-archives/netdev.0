From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cnic: Fix L2CTX_STATUSB_NUM offset in context memory.
Date: Wed, 28 Oct 2009 03:42:54 -0700 (PDT)
Message-ID: <20091028.034254.248169783.davem@davemloft.net>
References: <1256662728-21864-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davmloft.net, netdev@vger.kernel.org, benli@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40101
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751862AbZJ1Kmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 06:42:33 -0400
In-Reply-To: <1256662728-21864-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 27 Oct 2009 08:58:48 -0800

> The BNX2_L2CTX_STATUSB_NUM definition needs to be changed to match
> the recent firmware update:
> 
> commit 078b0735881c7969aaf21469f3577831cddd9f8c
> bnx2: Update firmware to 5.0.0.j3.
> 
> Without the fix, bnx2 can crash intermittently in bnx2_rx_int() when
> iSCSI is enabled.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied to net-2.6, but please be explicit about what tree you
want me to apply this to in the future.

Sure I could deduce this by running "git describe" on that
commit ID mentioned in the commit message, but why not be
explicit? :-)
