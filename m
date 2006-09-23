From: "Ray Lee" <madrabbit@gmail.com>
Subject: Re: Bcm43xx softMac Driver in 2.6.18
Date: Fri, 22 Sep 2006 23:03:30 -0700
Message-ID: <2c0942db0609222303o50e47156xe6af9a50ed8301c8@mail.gmail.com>
References: <4513E308.10507@lwfinger.net>
Reply-To: ray-gmail@madrabbit.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dbtsai@gmail.com, "John Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:34118 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1751094AbWIWGDb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 02:03:31 -0400
Received: by py-out-1112.google.com with SMTP id n25so1549467pyg
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 23:03:30 -0700 (PDT)
To: "Larry Finger" <Larry.Finger@lwfinger.net>
In-Reply-To: <4513E308.10507@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/22/06, Larry Finger <Larry.Finger@lwfinger.net> wrote:
> When we found the cause of NETDEV watchdog timeouts in the wireless-2.6 code,
> I knew that the 2.6.18 release code would cause a serious regression.

I don't know if this is the lockup you're trying to address, but
2.6.18's bcm43xx has definitely regressed for me versus 2.6.17.x.

2.6.18 vanilla and 2.6.18 with your patch both lock my system hard
with bcm43xx. I've got an HP/Compaq nx6125 laptop. Symptoms are that
it will associate fine on its own and send traffic to/fro upon ifup,
but when I do an iwconfig, ifdown, ifup to change the access point,
the system locks (somewhat randomly) during one of those operations.
Well, the iwconfig or the ifup, actually.

lspci -v:

02:02.0 Network controller: Broadcom Corporation BCM4309 802.11a/b/g (rev 03)
        Subsystem: Hewlett-Packard Company Unknown device 12f9
        Flags: bus master, fast devsel, latency 64, IRQ 11
        Memory at d0010000 (32-bit, non-prefetchable) [size=8K]

./bcm43xx-fwcutter -i BCMWL5.SYS
  filename :  bcmwl5.sys
  version  :  4.10.40.1
  MD5      :  69f940672be0ecee5bd1e905706ba8ce

Wireless tools are Version: 28-1ubuntu2.

I've got multiple access points in view of the laptop, a g (54Mb), and
a b (11Mb). Neither with encryption enabled, if that makes a
difference (we live in the boonies).

It's 2.6.18 + your patch, compiled for x86_64, ubuntu devel.

Any suggestions or requests for tests?

Ray
