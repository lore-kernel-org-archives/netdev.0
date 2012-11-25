From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: ipmr: various fixes and cleanups
Date: Sun, 25 Nov 2012 11:13:07 -0800
Message-ID: <1353870787.30446.831.camel@edumazet-glaptop>
References: <1353861705.30446.675.camel@edumazet-glaptop>
	 <1353868023.6558.10.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:35887 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753292Ab2KYTNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2012 14:13:16 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so7524959iay.19
        for <netdev@vger.kernel.org>; Sun, 25 Nov 2012 11:13:16 -0800 (PST)
In-Reply-To: <1353868023.6558.10.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-11-25 at 10:27 -0800, Joe Perches wrote:
> On Sun, 2012-11-25 at 08:41 -0800, Eric Dumazet wrote:
> > 4) " (v) ? 1 : 0 " can be written as " !!v "
> 
> Or maybe the compiler could do it by changing
> mroute_do_assert and mroute_do_pim to bool to
> save a few bytes per table too.
> 
> 

Yeah, but mroute is probably used only by a very limited
number of machines in the world.

Please submit an additional patch, as I already put too many
things in mine.
