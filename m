From: "Voluspa" <lista4@comhem.se>
Subject: Re: 2.6.8-rc4-bk1 problem: unregister_netdevice: waiting for ppp0
Date: Tue, 24 Aug 2004 00:31:14 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200408232231.i7NMVEh13558@d1o408.telia.com>
Reply-To: "Voluspa" <lista4@comhem.se>
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Patrick McHardy" <kaber@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

citerar Patrick McHardy:

> Did you also apply this patch ? If not, please try it and tell us
> if it helps.

No, haven't seen that one before. Ok, results:

01-2.6-cbq-leaks.diff aka [PKT_SCHED]: Fix class leak in CBQ scheduler
plus
[PKT_SCHED]: cacheline-align qdisc data in qdisc_create()

_Clean environment_

"shutdown -r now": OK
"rmmod 8139too"  : OK

_QoS through wshaper script_

"shutdown -r now": OK
"rmmod 8139too"  : OK

_Compiled kernel for size, no debugging_

Rest of my modules loaded. As above: OK and OK

Nice work. Thanks.

Mvh
Mats Johannesson
