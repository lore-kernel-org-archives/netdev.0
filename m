From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: pktgen scripts
Date: Wed, 13 May 2015 10:14:13 -0700
Message-ID: <55538665.4020201@plumgrid.com>
References: <20150513150237.0abf3628@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Robert Olsson <robert@herjulf.net>,
	Ben Greear <greearb@candelatech.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	Daniel Borkmann <borkmann@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:34627 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965027AbbEMROQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 13:14:16 -0400
Received: by igblo3 with SMTP id lo3so5797555igb.1
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 10:14:15 -0700 (PDT)
In-Reply-To: <20150513150237.0abf3628@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/13/15 6:02 AM, Jesper Dangaard Brouer wrote:
> Hi Alexei,
>
> I've cleaned up my pktgen scripts[1].  Do you think we should add them
> instead of the sample scripts in "samples/pktgen/pktgen.conf-*" ?

+1

> The main difference is I'm replacing the "pgset" with functions not
> needing global variable $PGDEV.  Three new functions reflect pktgen's
> different components:
>   * pg_ctrl()   control "pgctrl" (/proc/net/pktgen/pgctrl)
>   * pg_thread() control the kernel threads and binding to devices
>   * pg_set()    control setup of individual devices
>
> I've named the sample scripts: "pktgen_sample{01,02,03}_desc.sh" in-order
> to suggest a reading order.
> I've also added a script named: "pktgen_bench_xmit_mode_netif_receive.sh"
> which is basically your ingress benchmarking script.
>
> [1] https://github.com/netoptimizer/network-testing/tree/master/pktgen

Looks great!! Much better than old samples/pktgen/.
Could you add a readme file as well with few command line examples?
It wasn't obvious how '-b' and other flags are working. I guess if
somebody just tries to run them, the 'usage' function will explain
things too.
