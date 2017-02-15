From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: hip04: Omit private ndo_get_stats function
Date: Wed, 15 Feb 2017 02:28:08 -0800
Message-ID: <1487154488.6214.53.camel@perches.com>
References: <20170214141006.11510-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com
To: Tobias Klauser <tklauser@distanz.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0249.hostedemail.com ([216.40.44.249]:60725 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751304AbdBOK2M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 05:28:12 -0500
In-Reply-To: <20170214141006.11510-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-02-14 at 15:10 +0100, Tobias Klauser wrote:
> hip04_get_stats() just returns dev->stats so we can leave it
> out altogether and let dev_get_stats() do the job.

This could be done for at least a few more drivers:

drivers/net/ethernet/chelsio/cxgb/sge.c
drivers/net/ethernet/intel/e1000/e1000_main.c
drivers/net/ethernet/intel/ixgb/ixgb_main.c
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
