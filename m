From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NET 3.13.0-rc4 inconsistent lock state
 (&(&sk->sk_dst_lock)->rlock){+.?...}, at: [<ffffffff818a89e4>]
 __udp4_lib_rcv+0x9d4/0xa90
Date: Mon, 16 Dec 2013 07:22:52 -0800
Message-ID: <1387207372.19078.241.camel@edumazet-glaptop2.roam.corp.google.com>
References: <4810128955.20131216160609@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Durrant <Paul.Durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:50164 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754327Ab3LPPW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 10:22:56 -0500
Received: by mail-pa0-f43.google.com with SMTP id bj1so3079960pad.2
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 07:22:55 -0800 (PST)
In-Reply-To: <4810128955.20131216160609@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-16 at 16:06 +0100, Sander Eikelenboom wrote:
> On a Xen HVM guest i encountered this lock warning on boot, it looks like it's from the last net pull from Linus.
> Not sure if it's the Xen-changes or the udp4 ones.

This is the fourth report of this problem.

http://patchwork.ozlabs.org/patch/301382/

Thanks
