From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/5] gtp: clear DF bit on GTP packet tx
Date: Tue, 24 Jan 2017 20:17:03 +0100
Message-ID: <20170124191703.GB9897@salvia>
References: <20170124172402.12096-1-aschultz@tpip.net>
 <20170124172402.12096-3-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36460 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750708AbdAXTRI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 14:17:08 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 13F131EC2C2
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 20:17:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 05CDAA8258
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 20:17:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DE9A2A6C1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 20:17:04 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170124172402.12096-3-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 06:23:59PM +0100, Andreas Schultz wrote:
> 3GPP TS 29.281 and 3GPP TS 29.060 imply that GTP-U packets should be
> sent with the DF bit cleared. For example 3GPP TS 29.060, Release 8,
> Section 13.2.2:
> 
> > Backbone router: Any router in the backbone may fragment the GTP
> > packet if needed, according to IPv4.

Given this is fixing a broken implementation with regards to
standards, please target this to net.
