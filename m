From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] gtp: support SGSN-side tunnels
Date: Wed, 15 Mar 2017 18:23:48 +0100
Message-ID: <20170315172348.GA30592@salvia>
References: <20170203091231.10142-1-jonas@southpole.se>
 <20170315163916.gins7lzzqhwkvfrc@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jonas Bonn <jonas@southpole.se>, netdev@vger.kernel.org
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49618 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752844AbdCORX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 13:23:58 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 3CC751373A6
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:23:55 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2EBF9DA874
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:23:55 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id EE1F3DA86C
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:23:52 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170315163916.gins7lzzqhwkvfrc@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 15, 2017 at 05:39:16PM +0100, Harald Welte wrote:
> Hi Jonas,
> 
> are you working on the review feedback that was provided back in early
> February?  I think there were some comments like
> * remove unrelated cosmetic change in comment
> * change from FLAGS to a dedicated MODE netlink attribute
> * add libgtpnl code and some usage information or even sample scripts
> 
> I would definitely like to see this move forward, particularly in order
> to test the GGSN-side code.

Agreed.

It would be good if we provide a way to configure GTP via iproute2 for
testing purposes. We would need to create some dummy socket from
kernel too though so we don't need any userspace daemon for this
testing mode.
