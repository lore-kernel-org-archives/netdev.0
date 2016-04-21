From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 patch mysteriously breaks IPv4 VPN
Date: Thu, 21 Apr 2016 10:08:00 +0200
Message-ID: <57188A60.9060901@stressinduktion.org>
References: <15023.1461205453@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, bjorn@mork.no,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <15023.1461205453@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21.04.2016 04:24, Valdis Kletnieks wrote:
> I'll say up front - no, I do *not* have a clue why this commit causes this
> problem - it makes exactly zero fsking sense.
> 
> Scenario:  $WORK is blessed with a Juniper VPN system.  I've been
> seeing for a while now (since Dec-ish) an issue where at startup,
> the tun0 device will get wedged.  ifconfig reports this:
> 
> tun0: flags=4305<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST>  mtu 1400
>         inet 172.27.1.165  netmask 255.255.255.255  destination 172.27.1.165
>         inet6 fe80::6802:d95c:f3f4:2a6f  prefixlen 64  scopeid 0x20<link>
>         unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txqueuelen 500  (UNSPEC)
>         RX packets 0  bytes 0 (0.0 B)
>         RX errors 0  dropped 0  overruns 0  frame 0
>         TX packets 1  bytes 48 (48.0 B)
>         TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

Can you show us a ip -d l l ?

Thanks,
Hannes
