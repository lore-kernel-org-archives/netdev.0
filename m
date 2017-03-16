From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 07/10] netfilter: Force fake conntrack entry to be at
 least 8 bytes aligned
Date: Thu, 16 Mar 2017 09:55:29 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFB2547@AcuExch.aculab.com>
References: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
 <1489597272-30347-8-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Pablo Neira Ayuso' <pablo@netfilter.org>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.187]:52979 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751612AbdCPJzn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 05:55:43 -0400
In-Reply-To: <1489597272-30347-8-git-send-email-pablo@netfilter.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso
> Sent: 15 March 2017 17:01
> From: "Steven Rostedt (VMware)" <rostedt@goodmis.org>
> 
> Since the nfct and nfctinfo have been combined, the nf_conn structure
> must be at least 8 bytes aligned, as the 3 LSB bits are used for the
> nfctinfo. But there's a fake nf_conn structure to denote untracked
> connections, which is created by a PER_CPU construct. This does not
> guarantee that it will be 8 bytes aligned and can break the logic in
> determining the correct nfctinfo.

Can't you just add an __aligned(8) onto the structure definition?

	David
