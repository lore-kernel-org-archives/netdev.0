From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v3 0/2] GTP SGSN-side tunnels
Date: Fri, 24 Mar 2017 12:23:18 +0100
Message-ID: <20170324112318.GA1946@salvia>
References: <20170324093358.31374-1-jonas@southpole.se>
 <20170324101525.5i26wlg5jbsp6qrh@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jonas Bonn <jonas@southpole.se>, netdev@vger.kernel.org
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39940 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756641AbdCXLXa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 07:23:30 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id ACC4CE7B9C
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 12:23:21 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9E931DA862
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 12:23:21 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id BDB46DA862
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 12:23:18 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170324101525.5i26wlg5jbsp6qrh@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 24, 2017 at 11:15:25AM +0100, Harald Welte wrote:
> Hi Jonas,
> 
> looks fine to me, but I haven't tested it.  Did you manually test it
> using the extended libgtpnl + tools?
> 
> Also, in code like this:
> 
> +       if (gtp->role == GTP_ROLE_SGSN) {
> +               pctx = ipv4_pdp_find(gtp, iph->saddr);
> +       } else {
> 
> I think general Linux kernel coding style is to not have curly-brackets
> around single-line blocks. See "Do not unnecessarily use braces where a
> single statement will do." in line 169 of
> Documentation/process/coding-style.rst
> 
> I won't mind your current style, and it is not a blocker issue to me,
> but still it would be nice for general consistency.

Harald is right, I overlook this comestic thing.
