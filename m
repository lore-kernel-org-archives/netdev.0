From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 20/21] net: warn if drivers set tx_queue_len = 0
Date: Wed, 19 Aug 2015 13:33:40 -0700
Message-ID: <1440016420.6610.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439886649-24166-14-git-send-email-phil@nwl.cc>
	 <1439886649-24166-15-git-send-email-phil@nwl.cc>
	 <1439886649-24166-16-git-send-email-phil@nwl.cc>
	 <1439886649-24166-17-git-send-email-phil@nwl.cc>
	 <1439886649-24166-18-git-send-email-phil@nwl.cc>
	 <1439886649-24166-19-git-send-email-phil@nwl.cc>
	 <1439886649-24166-20-git-send-email-phil@nwl.cc>
	 <1439886649-24166-21-git-send-email-phil@nwl.cc>
	 <1439909248.6443.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150819183924.GA12537@orbit.nwl.cc> <20150819202104.GB12537@orbit.nwl.cc>
	 <1440016319.6610.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com, davem@davemloft.net
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36766 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436AbbHSUdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 16:33:42 -0400
Received: by pawq9 with SMTP id q9so10527847paw.3
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 13:33:42 -0700 (PDT)
In-Reply-To: <1440016319.6610.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-08-19 at 13:31 -0700, Eric Dumazet wrote:

> lpaa5:~# tc qd sh dev eth1
> qdisc mq 0: root 
> qdisc fq 0: parent :4 limit 10000p flow_limit 1000p buckets 1024 bands 3 priomap 1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1 quantum 3028 initial_quantum 15140 
> qdisc fq 0: parent :3 limit 10000p flow_limit 1000p buckets 1024 bands 3 priomap 1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1 quantum 3028 initial_quantum 15140 
> qdisc fq 0: parent :2 limit 10000p flow_limit 1000p buckets 1024 bands 3 priomap 1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1 quantum 3028 initial_quantum 15140 
> qdisc fq 0: parent :1 limit 10000p flow_limit 1000p buckets 1024 bands 3 priomap 1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1 quantum 3028 initial_quantum 15140 

Well, it seems I just leaked fact that we use 3-bands in our fq
implementation ;)
