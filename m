From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: pktgen: support injecting packets for qdisc testing
Date: Fri, 08 Jan 2016 13:36:04 -0800
Message-ID: <1452288964.8255.234.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160108020908.5940.89612.stgit@john-Precision-Tower-5810>
	 <568FD5B7.2060602@gmail.com> <568FD7FC.8020005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net, jhs@mojatatu.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36645 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754351AbcAHVgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 16:36:06 -0500
Received: by mail-pa0-f46.google.com with SMTP id yy13so195673518pab.3
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 13:36:06 -0800 (PST)
In-Reply-To: <568FD7FC.8020005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-08 at 07:38 -0800, John Fastabend wrote:

> Also I'll respin this with a change so xmit_{drop|cn|policed} are not
> counted as tx_bytes and pkts sent (idea from Jamal). However I won't
> abort the burst because I do like this stressing the entry point of my
> qdisc.

This reminds me that bonding/team drivers always return NETDEV_TX_OK
status, even if the chosen slave could not queue or send the packet.
