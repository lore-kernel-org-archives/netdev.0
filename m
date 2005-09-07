From: Marc Lehmann <schmorp@schmorp.de>
Subject: Re: Fw: masquerading failure for at least icmp and tcp+sack on amd64
Date: Wed, 7 Sep 2005 23:34:13 +0200
Message-ID: <20050907213413.GA8222@schmorp.de>
References: <20050907052057.09714a4c.akpm@osdl.org>
	<431EDF78.8060505@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <431EDF78.8060505@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 07, 2005 at 02:39:20PM +0200, Patrick McHardy <kaber@trash.net> wrote:
> Please try if loading the ipt_LOG module and executing
> "echo 255 > /proc/sys/net/ipv4/netfilter/ip_conntrack_log_invalid"
> gives more information

Some more messages I get when logging is enabled:

printk: 1286 messages suppressed.
ip_ct_tcp: invalid state IN= OUT= SRC=84.56.231.206 DST=xxx.xxx.xxx.xxx LEN=52 TOS=0x00 PREC=0x00 TTL=64 ID=3260 DF PROTO=TCP SPT=41535 DPT=119 SEQ=3475818900 ACK=1819416201 WINDOW=12198 RES=0x00 ACK URGP=0 OPT (0101080A00F5DE260917B744) UID=0 
printk: 1166 messages suppressed.
ip_ct_tcp: bad TCP checksum IN= OUT= SRC=xxx.xxx.xxx.xxx DST=84.56.231.206 LEN=1492 TOS=0x00 PREC=0x00 TTL=53 ID=6652 DF PROTO=TCP SPT=119 DPT=41550 SEQ=686563106 ACK=3472571721 WINDOW=55741 RES=0x00 ACK URGP=0 OPT (0101080A091782AB00F5E2EC) 
printk: 1114 messages suppressed.
ip_ct_tcp: bad TCP checksum IN= OUT= SRC=xxx.xxx.xxx.xxx DST=84.56.231.206 LEN=52 TOS=0x00 PREC=0x00 TTL=53 ID=45484 DF PROTO=TCP SPT=119 DPT=41550 SEQ=686606959 ACK=3472571737 WINDOW=55725 RES=0x00 ACK URGP=0 OPT (0101080A0917849E00F5E7B4) 
printk: 1214 messages suppressed.
ip_ct_tcp: bad TCP checksum IN= OUT= SRC=xxx.xxx.xxx.xxx DST=84.56.231.206 LEN=1492 TOS=0x00 PREC=0x00 TTL=53 ID=39527 DF PROTO=TCP SPT=119 DPT=41552 SEQ=2432945453 ACK=3473246510 WINDOW=56283 RES=0x00 ACK URGP=0 OPT (0101080A09182B2000F5ECAC) 
printk: 1320 messages suppressed.
ip_ct_tcp: bad TCP checksum IN= OUT= SRC=xxx.xxx.xxx.xxx DST=84.56.231.206 LEN=1492 TOS=0x00 PREC=0x00 TTL=52 ID=4867 DF PROTO=TCP SPT=119 DPT=41561 SEQ=1077509261 ACK=3487524170 WINDOW=56319 RES=0x00 ACK URGP=0 OPT (0101080A0917ABCD00F5F18F) 
printk: 1190 messages suppressed.
ip_ct_tcp: bad TCP checksum IN= OUT= SRC=xxx.xxx.xxx.xxx DST=84.56.231.206 LEN=1492 TOS=0x00 PREC=0x00 TTL=53 ID=7628 DF PROTO=TCP SPT=119 DPT=41538 SEQ=163747835 ACK=3477529327 WINDOW=56170 RES=0x00 ACK URGP=0 OPT (0101080A098F2AB200F5F682) 
printk: 1172 messages suppressed.

The corresponding connections work just fine, though (and I think I get
more than a single message for every physical packet received).

-- 
                The choice of a
      -----==-     _GNU_
      ----==-- _       generation     Marc Lehmann
      ---==---(_)__  __ ____  __      pcg@goof.com
      --==---/ / _ \/ // /\ \/ /      http://schmorp.de/
      -=====/_/_//_/\_,_/ /_/\_\      XX11-RIPE
