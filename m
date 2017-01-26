From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net v2 2/3] =?iso-8859-1?Q?gtp?=
 =?iso-8859-1?Q?=3A_clear_DF_bit_on_GTP_packet_tx=E7?=
Date: Thu, 26 Jan 2017 16:34:19 +0100
Message-ID: <20170126153419.GB1763@salvia>
References: <20170126151134.2892-1-aschultz@tpip.net>
 <20170126151134.2892-3-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50036 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753432AbdAZPed (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 10:34:33 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 0D13812067
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 16:34:27 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id F408FD191F
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 16:34:26 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C9496A7F24
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 16:34:24 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170126151134.2892-3-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 26, 2017 at 04:11:33PM +0100, Andreas Schultz wrote:
> 3GPP TS 29.281 and 3GPP TS 29.060 imply that GTP-U packets should be
> sent with the DF bit cleared. For example 3GPP TS 29.060, Release 8,
> Section 13.2.2:
> 
> > Backbone router: Any router in the backbone may fragment the GTP
> > packet if needed, according to IPv4.
> 
> Acked-by: Harald Welte <laforge@netfilter.org>
> Signed-off-by: Andreas Schultz <aschultz@tpip.net>

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
