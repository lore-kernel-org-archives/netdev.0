From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Strange CPU load when flushing route cache (kernel 2.6.31.6)
Date: Mon, 23 Nov 2009 15:03:29 +0100
Message-ID: <4B0A9631.2030705@gmail.com>
References: <1258970332.29747.262.camel@jdb-workstation>  <4B0A63FA.5000804@gmail.com> <1258979320.29747.270.camel@jdb-workstation> <4B0A8D41.6010608@gmail.com> <Pine.LNX.4.64.0911231437020.24347@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Robert Olsson <robert@herjulf.net>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36739 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752383AbZKWOD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 09:03:27 -0500
In-Reply-To: <Pine.LNX.4.64.0911231437020.24347@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> grep LowTotal /proc/meminfo
> LowTotal:         747080 kB
> 
> What does that mean?  Is it bad? What should I run on a 32-bit
> system/kernel?

If you have more than 1GB of physical ram, and use your machine as a router, you might
compile a 2GB/2GB User/Kernel kernel, to get twice available RAM for kernel
and more IP route entries (if needed)

make menuconfig
--> Processor type and features
  --> Memory split
    --> 2G/2G

> Can you recommend any other /proc/sys/ tuning options?

Really hard to say without exact context of use :)

> 
> Does my kernel boot option rhash_entries=262143 make sense anymore?
> Or do we adjust the hash bucket size dynamically these days?
> 

Its not dynamic yet.

