From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/6] cnic: Fine-tune CID memory space
 calculation.
Date: Fri, 25 Jun 2010 21:06:50 -0700 (PDT)
Message-ID: <20100625.210650.13760541.davem@davemloft.net>
References: <1277427522-17306-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38364
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751007Ab0FZEGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 00:06:37 -0400
In-Reply-To: <1277427522-17306-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 24 Jun 2010 17:58:37 -0700

> The current code makes assumptions about the CID (context ID) memory
> space and starting CID that may not be always correct when firmware
> changes.  In particular, BNX2_ISCSI_START_CID may not always be fixed.
> We now calculate cp->max_cid_space and cp->iscsi_start_cid dynamically
> instead of using fixed constants.  The unused cp->max_iscsi_conn is also
> eliminated.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
