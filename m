From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: dropwatch for network drop monitor
Date: Fri, 17 Apr 2009 16:16:10 +0200
Message-ID: <49E88F2A.4010301@hartkopp.net>
References: <200904171257.n3HCvOba029938@post.webmailer.de> <20090417132848.GA2723@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:8411 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760057AbZDQOQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 10:16:10 -0400
In-Reply-To: <20090417132848.GA2723@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Neil,

>> Initalizing kallsyms db
>> dropwatch> start
>> Enabling monitoring...
>> Waiting for activation ack....
>> Waiting for activation ack....
>> Waiting for activation ack....
>> Waiting for activation ack....
>> Waiting for activation ack....
>> Waiting for activation ack....
>> Failed activation request, error: Operation now in progress
>> Shutting down ...
>> vwagwolkf320:/home/hartko/dropwatch/src# 

Indeed i only get this the second time.

The first time i get

hartko@vwagwolkf320:~/dropwatch/src$ ./dropwatch
Initalizing kallsyms db
dropwatch> start
Enabling monitoring...
Kernel monitoring activated.
Issue Ctrl-C to stop monitoring

But Ctrl-C does not work. I only get 100% CPU load on the CPU executing dropwatch.

After killing the process, i get the above originally described behaviour.


>>
>> And in my kernel log i get at the same time:
>> [ 7070.568482] netlink: 60 bytes leftover after parsing attributes.

And this comes every time, i invoke dropwatch.

I'm running a debian system here on a Dell 830 Laptop with Core2Duo and the
latest linux-2.6 git

Regards,
Oliver

ps. Do i need to be root to run dropwatch?

