From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: IPv4: Attempt to release TCP socket in state 1
Date: Tue, 05 Mar 2013 06:46:35 -0800
Message-ID: <1362494795.15793.113.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1303041547080.7811@localhost6.localdomain6>
	  <51356AC1.4090302@gmail.com> <1362460046.15793.111.camel@edumazet-glaptop>
	 <alpine.DEB.2.02.1303042138330.7811@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dormando <dormando@rydia.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1303042138330.7811@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-03-04 at 21:44 -0800, dormando wrote:

> No 3rd party modules. There's a tiny patch for controlling initcwnd from
> userspace and another one for the extra_free_kbytes tunable that I brought
> up in another thread. We've had the initcwnd patch in for a long time
> without trouble. The extra_free_kbytes tunable isn't even being used yet,
> so all that's doing is adding a 0 somewhere.
> 
> Only two iptables rules loaded: global NOTRACK rules for PREROUTING/OUTPUT
> in raw.
> 
> Kernel's as close to pristine as I can make it. We had the 10g patch in
> but I've dropped it.
> --

Hmm, I spent time on this bug report but found nothing.

Please post as much information as you can on your setup.

I see you use macvlan, bridge, so maybe there is a configuration issue
(and a kernel bug of course)
