From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Multicast routing stops functioning after 4G multicast packets
 recived.
Date: Thu, 19 Dec 2013 09:24:18 -0800
Message-ID: <1387473858.19078.362.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131219162810.55810@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Bob Falken <NetFestivalHaveFun@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:59990 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900Ab3LSRYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 12:24:22 -0500
Received: by mail-pd0-f176.google.com with SMTP id w10so1376654pde.21
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 09:24:21 -0800 (PST)
In-Reply-To: <20131219162810.55810@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-19 at 17:28 +0100, Bob Falken wrote:
> The only reason why i give information about 2.6.36.4 is that its the
> only latest kernel that was functioning properly.
> i.e kernel >= 2.6.37 is not woking. so its a bisecting of the kernel
> versions to help a coder see when/where the isse was implemented in
> the kernel.
> 
> I do not need a backport patch for an old kernel, I generally only
> need the issue looked into and get fixed so that I dont have to use an
> old kernel. :)
> 
> I have no issue reproducing the issue on the recent kernels. however i
> have not tried the GIT kernel.
> 
> I restarted the server just a moment ago. i will install and run
> dropwatch and provide feedback in about 17hours. 

You said that "cat /proc/net/ip_mr_cache" gives nothing at all after
2^32 packets ?

Thats a bit scary ... maybe a 32bit refcnt overflow, because of some
imbalance...
