From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: sysctl net.ipv6.conf.eth0.use_tempaddr only recogniced on
 interface start?
Date: Mon, 30 Aug 2004 18:08:05 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830.180805.06423987.yoshfuji@linux-ipv6.org>
References: <F5812425CD96109163291692@worker.muc.bieringer.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi-users@linux-ipv6.org, netdev@oss.sgi.com,
        initscripts-ipv6@deepspace6.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pb@bieringer.de
In-Reply-To: <F5812425CD96109163291692@worker.muc.bieringer.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <F5812425CD96109163291692@worker.muc.bieringer.de> (at Mon, 30 Aug 2004 10:09:46 +0200), Peter Bieringer <pb@bieringer.de> says:

> during playing around with RFC3041 capability in Linux kernel, I recognized
> that the toggle (e.g. net.ipv6.conf.eth0.use_tempaddr) in sysctl is only
> recognized if interface state changes from down to up, which means you
> can't enable RFC3041 on an already running interface.

Not quite true. net.ipv6.conf.eth0.use_tempaddr is recognized, but 
new temporary addresses is created only when new public address is created
(by specification).

> Is this 
> 
> a) by design
> b) temporary issue, will be solved later
> c) bug, will be solved soon

a

and even b; we can probably extend our implementation 
to create temprary address when net.ipv6.conf.eth0.use_tempaddr is changed 
from 0 to 1.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
