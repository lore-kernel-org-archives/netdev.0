From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: Question about netlink
Date: Wed, 09 Jul 2003 04:04:33 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709.040433.89038276.yoshfuji@linux-ipv6.org>
References: <3F0B10E3.9050700@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: krkumar@us.ibm.com
In-Reply-To: <3F0B10E3.9050700@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <3F0B10E3.9050700@us.ibm.com> (at Tue, 08 Jul 2003 11:43:47 -0700), Krishna Kumar <krkumar@us.ibm.com> says:

> Some of the netlink routines (eg rtnetlink_dump_ifinfo or inet6_dump_ifaddr) seem to get
> user arguments from cb->args['n']. However I was not able to figure out where the
> arguments are being set, can anyone help ?

Take a look at net/core/rtnelink.c:rtnetlink_dump_ifinfo()
               net/core/neighbour.c:neigh_dump_{info,table}()
and seek the truth. :-)

--yoshfuji
