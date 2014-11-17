From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: /proc/net/sockstat invalid memory accounting or memory leak in
 latest =?UTF-8?Q?kernels=3F=20=28trying=20to=20debug=29?=
Date: Mon, 17 Nov 2014 17:33:41 +0200
Message-ID: <a65ec407c3f912b218469c16ea1fdfcd@visp.net.lb>
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
 <8d9b6a2c313db242c1afb3bcd6a12c51@visp.net.lb>
 <1416168961.17262.96.camel@edumazet-glaptop2.roam.corp.google.com>
 <1416200496.24093.5.camel@edumazet-glaptop2.roam.corp.google.com>
 <9056c6967a870d9fbee54776cf950e48@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:43893 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbaKQPdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 10:33:44 -0500
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 155EF480184
	for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 17:33:42 +0200 (EET)
In-Reply-To: <9056c6967a870d9fbee54776cf950e48@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-11-17 12:22, Denys Fedoryshchenko wrote:
>> Hmm.... I have an updated patch, sorry.
>> 
...
> 
> Installed patch, but will have to wait a while (usually at least
> 24hours), to be sure if it is stable.
> 
> Thanks a lot!
Tried updated patch, it seems crashed same after while with it too, and 
on second test i noticed same value overflow.

In debug, after i added alert if sk_forward_alloc > 1147483648 i noticed 
that on some sockets it continuously increasing this value until it will 
overflow.
I can provide logs if it is interesting.

I will try to sysctl fastopen to zero, to make sure if it changes 
anything.
