From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RCU lock bug in 3.0.21 (bisected to: 682cb56a, fix NULL
 dereferences in check_peer_redir)
Date: Tue, 27 Mar 2012 02:07:14 +0200
Message-ID: <1332806834.3547.16.camel@edumazet-glaptop>
References: <4F70E308.7070908@candelatech.com>
	 <20120326.174945.1186427809261872546.davem@davemloft.net>
	 <4F70E560.3020102@candelatech.com>  <4F70F688.6050108@candelatech.com>
	 <1332805148.3547.14.camel@edumazet-glaptop>
	 <4F70FFE0.7070204@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:33487 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752450Ab2C0AHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 20:07:18 -0400
Received: by eekc41 with SMTP id c41so1702425eek.19
        for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 17:07:17 -0700 (PDT)
In-Reply-To: <4F70FFE0.7070204@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-03-26 at 16:46 -0700, Ben Greear wrote:

> The 3.0.21 kernel doesn't appear to have a rcu_read_lock_return(),
> so I can't use your patch below.

This patch was only to show the point (I also CCed Paul, he might have
some time to think about it, after he clears the inline stuff with
Linus)

As I said, I was referreing to you adding stuff in rcu. ;)

Unfortunately I wont have time in the near future to do so myself.
