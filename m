From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Sun, 6 Mar 2005 18:31:45 +0100
Message-ID: <20050306173145.GQ31837@postel.suug.ch>
References: <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net> <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net> <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Mares <mj@ucw.cz>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
To: Zdenek Radouch <zdenek@rcn.com>
Content-Disposition: inline
In-Reply-To: <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hmmm, I don't seem to have the loopback interface...
> This table implies that 127.0.0.1 should go out via eth0
> to a gateway 192.168.13.264.  That's hard to believe.

It's in the local table

tgr:axs ~ ip route list dev lo table local
broadcast 127.255.255.255  proto kernel  scope link  src 127.0.0.1 
broadcast 127.0.0.0  proto kernel  scope link  src 127.0.0.1 
local 127.0.0.1  proto kernel  scope host  src 127.0.0.1 
local 127.0.0.0/8  proto kernel  scope host  src 127.0.0.1 
tgr:axs ~ ip route del 127.0.0.1 dev lo table local
tgr:axs ~ ip route del 127.0.0.0/8 dev lo table local
tgr:axs ~ ip route get 127.0.0.1
127.0.0.1 via 192.168.23.13 dev eth0  src 192.168.23.1 
    cache  mtu 1500 advmss 1460 metric10 64
