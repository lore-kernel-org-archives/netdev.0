From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: unregister_netdevice 2.6.9
Date: Wed, 20 Oct 2004 02:26:22 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020.022622.27982693.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.58LT.0410191738420.2725@lt.wsisiz.edu.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: lukasz@trabinski.net
In-Reply-To: <Pine.LNX.4.58LT.0410191738420.2725@lt.wsisiz.edu.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.58LT.0410191738420.2725@lt.wsisiz.edu.pl> (at Tue, 19 Oct 2004 17:58:58 +0200 (CEST)), Lukasz Trabinski <lukasz@trabinski.net> says:

> After shutdown/reboot :
> 
> unregister_netdevice: waiting for xxxx to become free. Usage count = 1
:
> whreis xxxx is name of sit device, created via script

Is your box acting as router, or host?
% sysctl -a |grep ipv6|grep forwarding

What is happend if you let the interface down and delete it before
becore rebooting?

Thanks.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
