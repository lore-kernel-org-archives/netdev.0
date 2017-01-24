From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 3/5] gtp: fix cross netns recv on gtp socket
Date: Tue, 24 Jan 2017 20:15:40 +0100
Message-ID: <20170124191540.GB9757@salvia>
References: <20170124172402.12096-1-aschultz@tpip.net>
 <20170124172402.12096-4-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36054 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750708AbdAXTPt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 14:15:49 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 7F7531EC2C2
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 20:15:47 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 6F875A7DB4
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 20:15:47 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 44FC3DA790
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 20:15:45 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170124172402.12096-4-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 06:24:00PM +0100, Andreas Schultz wrote:
> The use of the passed through netlink src_net to check for a
> cross netns operation was wrong. Using the GTP socket and the
> GTP netdevice is always correct (even if the netdev has been
> moved to new netns after link creation).
> 
> Remove the now obsolete net field from gtp_dev.

The net tree can take fixes anytime, so if you target this patch to
[PATCH net] this speeds up integration into mainline kernels. Note, as
soon as this patch hits Linus tree, we can request -stable submission
so older -stable kernels can get this.

If this follows the net-next path, then this fix is going to take
several weeks (sometimes months) to show in mainline kernels.

So please add [PATCH net] or [PATCH net-next] so it's clear to
everyone what is your target, David usually requests this.

BTW, probably you can target this small fix to net, then you can
request David to pull net into net-next so the fix propagates onwards.

Sorry for this bureaucratic stuff, but given the workload we deal
with, you will really helps us if you deal with these nitpicks.

Thanks Andreas!
