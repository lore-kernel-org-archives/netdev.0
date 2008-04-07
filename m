From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL net-2.6.26] [IPV6] MROUTE: Support multicast routing.
Date: Mon, 07 Apr 2008 23:37:09 +0900 (JST)
Message-ID: <20080407.233709.01728201.yoshfuji@linux-ipv6.org>
References: <147a89290804030016x7fc67a6bg56af8ed329c6a544@mail.gmail.com>
	<20080403.163144.18289606.yoshfuji@linux-ipv6.org>
	<147a89290804070613o5274432frb50995433a9a95f3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: johnsonzjo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:60919 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757826AbYDGOfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 10:35:30 -0400
In-Reply-To: <147a89290804070613o5274432frb50995433a9a95f3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <147a89290804070613o5274432frb50995433a9a95f3@mail.gmail.com> (at Mon, 7 Apr 2008 16:13:59 +0300), "Andy Johnson" <johnsonzjo@gmail.com> says:

>   I had compilation errors when trying to build pim6sd soleley , and
> it seems to me that the code should be changed for it to compile.

It SHOULD compile and work...
If you fail to build pim6sd, please drop a report to me.  Thanks.

> I found another PIM-sm open source project, which **does** build
> cleanly on my Linux box:
> It is mrd6:
> http://fivebits.net/proj/mrd6/
> 
> Perhaps you have any ideas:
> Should it work with  multicast routing with this kernel patch ? are
> there specific requirements which mcast-tools fulfiils (and maybe mrd6
> does not) ?

MRD6 seems independent from this kernel patch so far.
The kernel patch is regarding in-kernel multicast forwarding.

--yoshfuji
