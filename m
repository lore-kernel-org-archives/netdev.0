From: Crazy AMD K7 <snort2004@mail.ru>
Subject: Re[2]: do_IRQ: stack overflow: 872..
Date: Sat, 18 Dec 2004 19:07:42 +0300
Message-ID: <1421293830.20041218190742@mail.ru>
References: <1131604877.20041218092730@mail.ru.suse.lists.linux.kernel>
 <p73zn0ccaee.fsf@verdi.suse.de>
 <1103368330.3566.15.camel@localhost.localdomain>
 <20041218111420.GE338@wotan.suse.de>
 <1103370690.3566.33.camel@localhost.localdomain>
 <20041218135320.GA10030@wotan.suse.de>
Reply-To: Crazy AMD K7 <snort2004@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Bart De Schuymer <bdschuym@pandora.be>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-reply-To: <20041218135320.GA10030@wotan.suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Note to the original poster: when you report a bug with a patched
> kernel always mention it.
I have mentioned earlier and Bart knows it.

I use 2.4.28
+ ebtables-brnf-8_vs_2.4.28.diff
+ U32 patch from patch-o-matic-ng-20040621.tar.bz2
+ patch for br_netfilter.c made by Bart to find out why kernel panic happens(it was a few
  letters ago)
  All patches has applies cleanly.
  U32 doesn't affect on br_netfilter.c

[root@linux kernel]# md5sum linux-2.4.28.tar.bz2
ac7735000d185bc7778c08288760a8a3  linux-2.4.28.tar.bz2
(taken from http://www.ru.kernel.org/pub/linux/kernel/v2.4/linux-2.4.28.tar.bz2)

[root@linux bridge]# md5sum ebtables-brnf-8_vs_2.4.28.diff.gz
30542b1a7a502593afb4d37055ec5e35  ebtables-brnf-8_vs_2.4.28.diff.gz

[root@linux iptables]# md5sum patch-o-matic-ng-20040621.tar.bz2
4fd3c744bf55f119fef6c7c3c4acc4b6  patch-o-matic-ng-20040621.tar.bz2

If the problem will continue appear and will not be solved an any
way, of course, I will use 2.6 kernel, now I am not ready to use it.

Pasha
