From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-2.6] net_sched: always clone skbs
Date: Tue, 21 Dec 2010 08:52:54 -0500
Message-ID: <1292939574.6535.27.camel@mojatatu>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
	 <20101220232020.GB2052@del.dom.local>
	 <1292887689.2627.150.camel@edumazet-laptop>
	 <20101220235209.GA1865@del.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Pawel Staszewski <pstaszewski@itcare.pl>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:52239 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140Ab0LUNxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 08:53:02 -0500
Received: by gxk19 with SMTP id 19so2233696gxk.11
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 05:53:01 -0800 (PST)
In-Reply-To: <20101220235209.GA1865@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-12-21 at 00:52 +0100, Jarek Poplawski wrote:


> 
> host1 (kernel 2.6.36.2)
> netperf client -> eth3 (82598EB 10-Gigabit AT CX4) - directly connected to eth2 of host2
> ethtool -k eth3
> Offload parameters for eth3:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: on
> udp-fragmentation-offload: off
> generic-segmentation-offload: on
> generic-receive-offload: on 

Use to be we couldnt get the ifb+mirred combo to work
with TSO even without this change - i will have to dig old emails
to remember details. So we are making progress;-> I did write a set
of rules in: Documentation/networking/tc-actions-env-rules.txt
Changli optimized rule #1. When i looked at his patch it seems
to not harm that case. Sometimes dumb is a good principle ;->

cheers,
jamal

