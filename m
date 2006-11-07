From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 4/8] subdance: fix TX Pause bug (reset_tx, intr_handler)
Date: Tue, 07 Nov 2006 04:37:34 -0500
Message-ID: <455053DE.5070107@garzik.org>
References: <200610202142.k9KLgBKA003722@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@icplus.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:64179 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1754155AbWKGJhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 04:37:36 -0500
To: akpm@osdl.org
In-Reply-To: <200610202142.k9KLgBKA003722@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Jesse Huang <jesse@icplus.com.tw>
> 
> Fix TX Pause bug (reset_tx, intr_handler).  When MaxCollisions occurred, need
> to re-enable Tx.  But just after re-enable, MaxCollisions maybe occurred again
> and with TxStatusOverflow.  This will cause driver can't check new
> MaxCollisions to re-enable Tx again, because TxStatusOverflow.  For this
> reason, after re-enable Tx, we need to make sure Tx was actually enabled.
> 
> Signed-off-by: Jesse Huang <jesse@icplus.com.tw>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

applied


