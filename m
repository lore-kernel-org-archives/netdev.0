From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 3/8] sundance: remove TxStartThresh and RxEarlyThresh
Date: Tue, 07 Nov 2006 04:37:24 -0500
Message-ID: <455053D4.6020307@garzik.org>
References: <200610202142.k9KLg5W6003719@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@icplus.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:62387 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1754153AbWKGJh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 04:37:27 -0500
To: akpm@osdl.org
In-Reply-To: <200610202142.k9KLg5W6003719@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Jesse Huang <jesse@icplus.com.tw>
> 
> For patent issue need to remove TxStartThresh and RxEarlyThresh.  This patent
> is cut-through patent.  If use this function, Tx will start to transmit after
> few data be move in to Tx FIFO.  We are not allow to use those function in
> DFE530/DFE550/DFE580/DL10050/IP100/IP100A.  It will decrease a little
> performance.
> 
> Signed-off-by: Jesse Huang <jesse@icplus.com.tw>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

applied


