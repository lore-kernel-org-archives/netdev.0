From: Michal Soltys <soltys@ziu.info>
Subject: Re: pkt_sched: Fix qdisc len in qdisc_peek_dequeued() [61c9eaf9008]
 - question
Date: Sun, 16 Nov 2014 22:09:21 +0100
Message-ID: <54691281.5020002@ziu.info>
References: <5468A0C5.9010409@ziu.info> <1416161725.17262.92.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:4000 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750741AbaKPVRt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Nov 2014 16:17:49 -0500
In-Reply-To: <1416161725.17262.92.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Actually, now that I analyzed it more carefully - not having that patch 
would cause obvious issues (e.g. hfsc trying to activate already active 
leaf in certain scenarios).

So, sorry for the noise.

PS.
Removed Jarek from CC, as that email is no longer valid.
