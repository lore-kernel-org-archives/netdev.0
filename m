From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: /proc/net/sockstat invalid memory accounting or memory leak in
 latest kernels? (trying to debug)
Date: Sun, 16 Nov 2014 11:10:02 -0800
Message-ID: <1416165002.17262.94.camel@edumazet-glaptop2.roam.corp.google.com>
References: <40bc2b5fcda47d790f1fd247bc409041@visp.net.lb>
	 <1405597918.10255.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <37e25a5815a18a2da507a5b20b58427d@visp.net.lb>
	 <1405604568.10255.80.camel@edumazet-glaptop2.roam.corp.google.com>
	 <a927787503c2f0d71c330b879303b14f@visp.net.lb>
	 <1405672897.10255.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1405676214.10255.96.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0b0b74ab8d2222fa85b23e06c6e992ec@visp.net.lb>
	 <1405849675.10255.100.camel@edumazet-glaptop2.roam.corp.google.com>
	 <6fc086a122bc3ac728a7aec9e812310f@visp.net.lb>
	 <1406016045.10255.122.camel@edumazet-glaptop2.roam.corp.google.com>
	 <3f463c3912608f7959481edaa6d7668d@visp.net.lb>
	 <1406194817.3363.70.camel@edumazet-glaptop2.roam.corp.google.com>
	 <8f138d88e3b850130eb9bb15e3e27069@visp.net.lb>
	 <2adbf5346b4dd2bebe1915096c1c567c@visp.net.lb>
	 <1415813254.17262.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <64ef227cf22945d373cb06271fe6e051@visp.net.lb>
	 <1416161495.17262.90.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:41306 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755409AbaKPTKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 14:10:01 -0500
Received: by mail-ig0-f175.google.com with SMTP id h15so2269453igd.8
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 11:10:00 -0800 (PST)
In-Reply-To: <1416161495.17262.90.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-11-16 at 10:11 -0800, Eric Dumazet wrote:

> Could you describe your hardware setup and networking setup ?

Hmmm, this looks like a bug in TCP fast open.

I am cooking a patch.
