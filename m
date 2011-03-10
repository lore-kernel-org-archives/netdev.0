From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Mass udp flow reboot linux with RealTek RTL-8169 Gigabit
Date: Thu, 10 Mar 2011 13:08:56 +0100
Message-ID: <20110310120856.GA14219@electric-eye.fr.zoreil.com>
References: <AANLkTin7GBSTcfZgr_9sNZ8CPMkW7Vstni+fs2v1-ink@mail.gmail.com> <1297581470.2510.18.camel@edumazet-laptop> <20110213135600.GA11382@electric-eye.fr.zoreil.com> <AANLkTikTw71-mv9WsPT8PxC1a1nwEJ=x0UNDhVQGP1A6@mail.gmail.com> <AANLkTikLOJ-XcwfdbWS19DKzh2s91tn5pQjJe0+CeAN-@mail.gmail.com> <20110213203417.GA11442@electric-eye.fr.zoreil.com> <AANLkTi=PrOXMD54hSbEwUtmzXiwsSwiSijE3AJ9n=WDe@mail.gmail.com> <20110218093000.GA12106@electric-eye.fr.zoreil.com> <AANLkTim6tt4yC+1VQ3AtDMf1KKLRqf5kErpipqNSbQkX@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Ivan Vecera <ivecera@redhat.com>
To: Seblu <seblu@seblu.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTim6tt4yC+1VQ3AtDMf1KKLRqf5kErpipqNSbQkX@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Seblu <seblu@seblu.net> :
[...]
> I catched the following trace during my previous torture session.
> Maybe it can help.

It's the usual r8169 TX timeout watchdog.

[...]
> > Can you apply the two attached patches on top of the previous ones and
> > give it a try ? The debug should not be too verbose if things are stationary
> > enough.
> 2.6.38-rc7 with your 2 previous patch change the game. No reboot. No
> strange message in dmesg.

?

"strange message" as :
[ ] netdev watchdog messages
[ ] 0001 0001 0001 0001 (or similar) message
[ ] net_ratelimit message

> But some sent packets are lost from some host. Example:
[...]
> This is maybe normal under stress, card discard packet after all.

It seems so. 0.08% packet loss. 10 ~ 20kpps (right ?). Sample at 0.1 Hz (ping).

[...]
> I've a serial cable and a second computer, but my first computer
> doesn't have a com port. Is it then possible?

Hardly. Forget it for now.

> Do you need more test?

1. 2.6.38-rc7 without the patches
2. 2.6.38-rc7 with the r8169.c driver of 2.6.38-rc5, without the patches
3. current setup + pktgen. Lower the packet size as long as it increases
   the sender's pps.

I do not understand why the bug would be gone if it was in the r8169
proper.

-- 
Ueimor
