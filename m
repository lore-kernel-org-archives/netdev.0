From: Patrick McHardy <kaber@trash.net>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!	2.6.28
Date: Tue, 13 Jan 2009 05:33:14 +0100
Message-ID: <496C198A.4060502@trash.net>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <200901122038.05199.denys@visp.net.lb> <Pine.LNX.4.64.0901122052510.4748@ask.diku.dk> <200901122201.19616.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47012 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753418AbZAMEdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 23:33:18 -0500
In-Reply-To: <200901122201.19616.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko wrote:
> They are enabled
> 
> Router-Dora /config # zcat /proc/config.gz |grep HIGH_RES
> CONFIG_HIGH_RES_TIMERS=y
> Router-Dora /config # zcat /proc/config.gz |grep HZ
> CONFIG_NO_HZ=y

Its odd that HZ=1000 solved the problem despite HR timers being active.
Are you sure they're actually enabled? You should see something like
this in the ringbuffer:

[    0.241972] Switched to high resolution mode on CPU 0
[    0.242708] Switched to high resolution mode on CPU 1
