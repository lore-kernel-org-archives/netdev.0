From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] gtp: support SGSN-side tunnels
Date: Wed, 15 Mar 2017 22:42:33 +0100
Message-ID: <20170315214233.GA1189@salvia>
References: <20170203091231.10142-1-jonas@southpole.se>
 <20170315163916.gins7lzzqhwkvfrc@nataraja>
 <20170315172348.GA30592@salvia>
 <20170315191038.nco2icu6e545rzlu@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jonas Bonn <jonas@southpole.se>, netdev@vger.kernel.org,
        osmocom-net-gprs@lists.osmocom.org
To: Harald Welte <laforge@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40612 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753314AbdCOVms (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 17:42:48 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id E0FBA174D04
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 22:42:43 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D0438DA872
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 22:42:43 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 60888DA848
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 22:42:41 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170315191038.nco2icu6e545rzlu@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Harald,

On Wed, Mar 15, 2017 at 08:10:38PM +0100, Harald Welte wrote:
> I've modified the patch slightly, see below (compile-tested, but not
> otherwise tested yet).  Basically rename the flags attribute to 'role',
> expand the commit log and removed unrelated cosmetic changes.
> 
> I've also prepared a corresponding change to libgtpnl into the
> laforge/sgsn-rol branch, see
> http://git.osmocom.org/libgtpnl/commit/?h=laforge/sgsn-role
> 
> This is not yet tested in any way, but I'm planning to add some
> associated support to the command line tools and then give it some
> testing (both against the kernel GTP in GGSN mode, as well as an
> independent userspace GTP implementation).

Thanks Harald.

> > It would be good if we provide a way to configure GTP via iproute2 for
> > testing purposes.
> 
> I don't really care about which tool is used, as long as it is easily
> available [and FOSS, of course].
>
> > We would need to create some dummy socket from
> > kernel too though so we don't need any userspace daemon for this
> > testing mode.
> 
> I don't really like that latter idea. It sounds too much like a hack to
> me.  But then, I don't have enough phantasy right now ti imagine how an
> actual implementation would look like.

It's not that far away, we can just create the udp socket from
kernelspace via udp_sock_create() in the test mode. So we don't need
to pass the file descriptor from userspace. But not asking you to work
on this, just an idea.

> To me, it is perfectly fine to run a simple, small utility in userspace
> even for testing.

No problem.
