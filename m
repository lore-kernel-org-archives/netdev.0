From: Patrick McHardy <kaber@trash.net>
Subject: Re: spin_trylock in qdisc_restart, OOPS, IMQ problem ?
Date: Wed, 02 Mar 2005 11:28:46 +0100
Message-ID: <4225955E.7030306@trash.net>
References: <42258DC6.9030109@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Martin Devera <devik@cdi.cz>
In-Reply-To: <42258DC6.9030109@cdi.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Martin Devera wrote:
> I've seen some notes in 2.6.11rc3 changelog from Patrick about
> issues similar to my OOPS (attached).
> Patrick, does the oops ring some bells at your side ?

The fixes in 2.6.11-rc3 fixed some new bugs introduced in -rc2. This
looks like a problem with non-linear skbs, this patch from Rusty may
help:

http://linux.bkbits.net:8080/linux-2.6/cset@41db69b71pSJFXrCtc56tffafab_JQ?nav=index.html|src/net/|src/net|src/net/ipv4|src/net/ipv4/netfilter|related/net/ipv4/netfilter/ip_nat_proto_tcp.c

Regards
Patrick
