From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Via Rhine II Network Card Failure
Date: Wed, 4 Jul 2007 14:11:41 +0200
Message-ID: <20070704121141.GA3996@ff.dom.local>
References: <665527d90706210358k5a1d27f2r30536547f447a516@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Satyam Sharma <satyam.sharma@gmail.com>
To: Mark Hannessen <markhannessen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:45561 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759360AbXGDMDQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 08:03:16 -0400
Content-Disposition: inline
In-Reply-To: <665527d90706210358k5a1d27f2r30536547f447a516@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21-06-2007 12:58, Mark Hannessen wrote:
> Hi list,
> 
> I have some trouble getting my network card to run.
> when I run dmesg I can clearly see it being detected
> 
> eth0: VIA Rhine II at 0xee006000, 00:e0:c5:54:88:a8, IRQ 11.
> eth0: MII PHY found at address 1, status 0x786d advertising 05e1 Link 45e1.
> 
> but when I try ifconfig eth0 up it fails with a no device error.
> 
> SIOCSIFADDR: No such device eth0:
> ERROR while getting interface flags: No such device
> 
> I tried adding pci=routeirq too, but that didn't work either.
> 
> I know there is nothing wrong with the card itself because it works on
> the linux distro that came with it.
> 
> does anyone have any hints as to what might get it up and running?

I see the list has been really overworked...

It's a long time and I hope you've found the reason yet.
If not, here are some hints:

- is eth0 shown in /proc e.g. in /proc/interrupts?
- is ifconfig -a returning something?
- can you try ip (from iproute package) e.g. ip link set eth0 up
- do you have the same net options enabled as in this distro:
  e.g. CONFIG_PACKET?
- maybe you can try to figure something after (as root):
  strace ifconfig eth0 up
or send the output here...

Regards,
Jarek P.
