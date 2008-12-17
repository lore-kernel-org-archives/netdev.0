From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Lockup with tun/tap/bridge interface deregistration.
Date: Wed, 17 Dec 2008 12:23:50 +0000
Message-ID: <20081217122350.GA6480@ff.dom.local>
References: <87fxkwhyyq.fsf@barad-dur.regala.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kernel@gentoo.org
To: Mathieu SEGAUD <mathieu.segaud@regala.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:65507 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751040AbYLQMX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 07:23:58 -0500
Received: by ewy10 with SMTP id 10so4258023ewy.13
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 04:23:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <87fxkwhyyq.fsf@barad-dur.regala.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-12-2008 15:44, Mathieu SEGAUD wrote:
> Hi,
> 
> we are experiencing some "virtual" network interfaces problem, especially
> with tun/tap devices and with bridges, which occasionally get stuck and
> won't deregister and hang the destroying process for very long time.
...
>  [<c0266b41>] netdev_run_todo+0xf7/0x19d
>  [<f8a7f3c5>] br_del_bridge+0x48/0x4c [bridge]
...
> (This one was obtained with kernel version 2.6.27.4)
> 

I wonder if it's related but since it was originally reported for
2.6.24 kernel, and there was a substantial change around this in dst
code, it would be very interresting to try 2.6.23 for this.

Thanks,
Jarek P.
