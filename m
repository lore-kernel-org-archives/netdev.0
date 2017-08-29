From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net] nfp: double free on error in probe
Date: Tue, 29 Aug 2017 13:05:56 -0700
Message-ID: <20170829130556.7632d5ed@cakuba>
References: <20170829190855.fabfktv2dg57x3gs@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Simon Horman <simon.horman@netronome.com>,
        oss-drivers@netronome.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36100 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbdH2UGC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 16:06:02 -0400
Received: by mail-pf0-f174.google.com with SMTP id z87so13119957pfi.3
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 13:06:01 -0700 (PDT)
In-Reply-To: <20170829190855.fabfktv2dg57x3gs@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Aug 2017 22:15:16 +0300, Dan Carpenter wrote:
> Both the nfp_net_pf_app_start() and the nfp_net_pci_probe() functions
> call nfp_net_pf_app_stop_ctrl(pf) so there is a double free.  The free
> should be done from the probe function because it's allocated there so
> I have removed the call from nfp_net_pf_app_start().
> 
> Fixes: 02082701b974 ("nfp: create control vNICs and wire up rx/tx")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>
