From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next 0/4] gtp: support multiple APN's per GTP endpoint
Date: Tue, 14 Mar 2017 12:45:38 +0100
Message-ID: <20170314114538.GC2992@salvia>
References: <20170314112548.24027-1-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harald Welte <laforge@gnumonks.org>,
        osmocom-net-gprs@lists.osmocom.org,
        netdev <netdev@vger.kernel.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42392 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750992AbdCNLpw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 07:45:52 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id BB23F24717
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 12:45:44 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A9C48DA865
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 12:45:44 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5D11BDA879
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 12:45:42 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170314112548.24027-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 12:25:44PM +0100, Andreas Schultz wrote:
[...]
> API impact:
> -----------
> 
> This is probably the most problematic part of this series...
> 
> The removeal of the TEID form the netdevice also means that the gtp genl API
> for retriving tunnel information and removing tunnels needs to be adjusted.
> 
> Before this change it was possible to change a GTP tunnel using the gtp
> netdevice id and the teid. The teid is no longer unique per gtp netdevice.
> After this change it has to be either the netdevice and MS IP or the GTP
> socket and teid.

Then we have to introduce some explicit VRF concept or such to sort
out this.

It is definitely not acceptable to break the existing API.
