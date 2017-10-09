From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v3] netfilter: SYNPROXY: fix process non tcp packet bug
 in {ipv4,ipv6}_synproxy_hook
Date: Mon, 9 Oct 2017 13:09:06 +0200
Message-ID: <20171009110906.GA4025@salvia>
References: <1507221843-4915-1-git-send-email-xiaolou4617@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org
To: Lin Zhang <xiaolou4617@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:39798 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751598AbdJILJO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 07:09:14 -0400
Content-Disposition: inline
In-Reply-To: <1507221843-4915-1-git-send-email-xiaolou4617@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 06, 2017 at 12:44:03AM +0800, Lin Zhang wrote:
> In function {ipv4,ipv6}_synproxy_hook we expect a normal tcp packet,
> but the real server maybe reply an icmp error packet related to the
> exist tcp conntrack, so we will access wrong tcp data.
> 
> For fix it, check for the protocol field and only process tcp traffic.

Applied, thanks. I have mangled the title slightly to:

        netfilter: SYNPROXY: skip non-tcp packet in {ipv4, ipv6}_synproxy_hook

For the record.
