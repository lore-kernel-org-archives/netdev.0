From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: Changes for new firmware 1.14.4.0
Date: Wed, 09 Sep 2015 12:33:59 -0700 (PDT)
Message-ID: <20150909.123359.137728939050408728.davem@davemloft.net>
References: <1441627850-5610-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbbIITeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 15:34:01 -0400
In-Reply-To: <1441627850-5610-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Mon,  7 Sep 2015 17:40:50 +0530

> Incorporate fw_ldst_cmd structure change for new firmware and also
> update version string for the same
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

This doesn't apply cleanly at all, please respin as it has to
take into account commit:

commit a69265e9f65a6747c27b01b4030ad85d71aa11ba
Author: Hariprasad Shenai <hariprasad@chelsio.com>
Date:   Fri Aug 28 11:17:12 2015 +0530

    cxgb4: Force uninitialized state if FW in adapter is unsupported
    
    Forcing uninitialized state allows us to upgrade and reinitialize
    the adapter.
    
        FW_VERSION_T4 = 1.4.0.0
        FW_VERSION_T5 = 0.0.0.0
        FW_VERSION_T6 = 0.0.0.0
    At this point driver supports above and greater than above version.
    
    If FW in adapter < min FW_VERSION driver supports tries to upgrade the FW
    If FW in adapter >= FW_VERSION driver supports then it follows normal path
    
    Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
