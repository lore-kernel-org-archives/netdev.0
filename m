From: Thomas Graf <tgraf@suug.ch>
Subject: Re: race in net/ipv4/ipip.c ?
Date: Wed, 12 Jan 2005 14:21:26 +0100
Message-ID: <20050112132126.GI26856@postel.suug.ch>
References: <20050112122300.GA12155@xi.wantstofly.org> <20050112125336.GH26856@postel.suug.ch> <20050112130940.GA12547@xi.wantstofly.org> <20050112122300.GA12155@xi.wantstofly.org> <20050112125336.GH26856@postel.suug.ch> <20050112.220816.56650893.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
        Lennert Buytenhek <buytenh@wantstofly.org>
Content-Disposition: inline
In-Reply-To: <20050112130940.GA12547@xi.wantstofly.org> <20050112.220816.56650893.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* YOSHIFUJI Hideaki / ?$B5HF#1QL@ <20050112.220816.56650893.yoshfuji@linux-ipv6.org> 2005-01-12 22:08
> How about adding multiple tunnels (with same ipip_bucket(t))
> concurrently? :-)
> 

* Lennert Buytenhek <20050112130940.GA12547@xi.wantstofly.org> 2005-01-12 14:09
> What if you add two tunnels at the same time?  (Or is that perhaps
> synchronised on a higher level?)

Not possible, protected via rtnl semaphore acquired in default
handler of dev_ioctl.
