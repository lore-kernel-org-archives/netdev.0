From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] nfp: double free on error in probe
Date: Tue, 29 Aug 2017 16:07:39 -0700 (PDT)
Message-ID: <20170829.160739.1984273425912196249.davem@davemloft.net>
References: <20170829190855.fabfktv2dg57x3gs@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, simon.horman@netronome.com,
        oss-drivers@netronome.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41102 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751374AbdH2XHk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 19:07:40 -0400
In-Reply-To: <20170829190855.fabfktv2dg57x3gs@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 29 Aug 2017 22:15:16 +0300

> Both the nfp_net_pf_app_start() and the nfp_net_pci_probe() functions
> call nfp_net_pf_app_stop_ctrl(pf) so there is a double free.  The free
> should be done from the probe function because it's allocated there so
> I have removed the call from nfp_net_pf_app_start().
> 
> Fixes: 02082701b974 ("nfp: create control vNICs and wire up rx/tx")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
