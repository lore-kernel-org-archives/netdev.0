From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.9.5+:  Crash in tcp_input.c:4810.
Date: Tue, 02 Jul 2013 22:02:29 -0700
Message-ID: <1372827749.4979.52.camel@edumazet-glaptop>
References: <51BF50B3.1080403@candelatech.com>
	   <1371493059.3252.200.camel@edumazet-glaptop>
	   <51D1C620.8030007@candelatech.com>
	  <1372813467.4979.46.camel@edumazet-glaptop>
	  <51D398C0.5060802@candelatech.com>
	 <1372826512.4979.49.camel@edumazet-glaptop>
	 <51D3AD66.8030506@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:56708 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830Ab3GCFCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 01:02:30 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so4254864pdj.17
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 22:02:30 -0700 (PDT)
In-Reply-To: <51D3AD66.8030506@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-02 at 21:49 -0700, Ben Greear wrote:

> Well, network emulators are easy to come by in the office....  Maybe running
> a bunch of TCP connections through a lossy network would exercise this code
> path a bit?  Aside from random pkt loss, any other types of network conditions
> that might help trigger this faster?
> 
> I'll set up some tests using some wired ethernet...if we can trigger it there
> then we at least know it doesn't depend on ath9k...

I tried a lot of things, including netem with many reorders and/or
packetdrill tests, but so far not a single warning from tcp_collapse()
