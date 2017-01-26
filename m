From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net v2 3/3] gtp: fix cross netns recv on gtp socket
Date: Thu, 26 Jan 2017 16:34:40 +0100
Message-ID: <20170126153440.GC1763@salvia>
References: <20170126151134.2892-1-aschultz@tpip.net>
 <20170126151134.2892-4-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50268 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753368AbdAZPeu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 10:34:50 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 4E4D01125E
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 16:34:48 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3B4AEA7DC6
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 16:34:48 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 6AC81A7BF0
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 16:34:45 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170126151134.2892-4-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 26, 2017 at 04:11:34PM +0100, Andreas Schultz wrote:
> The use of the passed through netlink src_net to check for a
> cross netns operation was wrong. Using the GTP socket and the
> GTP netdevice is always correct (even if the netdev has been
> moved to new netns after link creation).
> 
> Remove the now obsolete net field from gtp_dev.
> 
> Signed-off-by: Andreas Schultz <aschultz@tpip.net>

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
