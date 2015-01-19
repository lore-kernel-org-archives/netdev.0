From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Sun, 18 Jan 2015 19:13:17 -0800
Message-ID: <289C7DCC-D2B3-43B6-B661-EE19371D8B17@holtmann.org>
References: <20150119140610.6b41b5ef@canb.auug.org.au>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150119140610.6b41b5ef@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

> After merging the net-next tree, today's linux-next build (powerpc
> ppc64_defconfig) failed like this:
> 
> In file included from net/bridge/br.c:22:0:
> include/net/switchdev.h:73:1: error: expected identifier or '(' before '{' token
> {
> ^
> include/net/switchdev.h:71:19: warning: 'call_netdev_switch_notifiers' declared 'static' but never defined [-Wunused-function]
> static inline int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
>                   ^
> 
> Caused by commit 03bf0c281234 ("switchdev: introduce switchdev notifier").
> 
> I have used the net-next tree from next-20150116 for today.  I also had
> to use the bluetooth tree from next-20150116 as it was fast forwarded
> to be the same as the net-next tree today.

it seems Dave forgot to push out his net-next tree, but in theory it should contain a fix for it.

Regards

Marcel
