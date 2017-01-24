From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 4/5] gtp: remove unnecessary rcu_read_lock
Date: Tue, 24 Jan 2017 20:17:32 +0100
Message-ID: <20170124191732.GC9897@salvia>
References: <20170124172402.12096-1-aschultz@tpip.net>
 <20170124172402.12096-5-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36634 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750786AbdAXTRh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 14:17:37 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id B28821EC2CA
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 20:17:35 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A4B5EA8258
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 20:17:35 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 86A48FEFB1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 20:17:33 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170124172402.12096-5-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 06:24:01PM +0100, Andreas Schultz wrote:
> The rcu read lock is hold by default in the ip input path. There
> is no need to hold it twice in the socket recv decapsulate code path.

I think this is net-next material since it is not essencial.
