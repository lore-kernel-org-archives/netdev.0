From: Marc Lehmann <schmorp@schmorp.de>
Subject: Re: Fw: masquerading failure for at least icmp and tcp+sack on amd64
Date: Wed, 7 Sep 2005 23:54:07 +0200
Message-ID: <20050907215407.GC8222@schmorp.de>
References: <20050907052057.09714a4c.akpm@osdl.org>
	<431EDF78.8060505@trash.net> <20050907213413.GA8222@schmorp.de>
	<431F5EA9.8020601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <431F5EA9.8020601@trash.net>
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

On Wed, Sep 07, 2005 at 11:42:01PM +0200, Patrick McHardy <kaber@trash.net> wrote:
> > Some more messages I get when logging is enabled:
> > 
> > printk: 1286 messages suppressed.
> > ip_ct_tcp: invalid state IN= OUT= SRC=84.56.231.206 DST=xxx.xxx.xxx.xxx LEN=52 TOS=0x00 PREC=0x00 TTL=64 ID=3260 DF PROTO=TCP SPT=41535 DPT=119 SEQ=3475818900 ACK=1819416201 WINDOW=12198 RES=0x00 ACK URGP=0 OPT (0101080A00F5DE260917B744) UID=0 
> > printk: 1166 messages suppressed.
> 
> This doesn't tell much since we don't know what happend to the
> connection before. You can disable message surpressing by echoing
> 0 to /proc/sys/net/core/message_cost. I had a beer too much for
> serious debugging,
   
Well, as long as you can think of simple patches, that's just fine :)

> just to give some hints, does this patch make the problem go away?

I guess now that hw checksumming is identified as the direct cause, this is
no longer neecssary? If yes, just tell me and I'll try it out.

-- 
                The choice of a
      -----==-     _GNU_
      ----==-- _       generation     Marc Lehmann
      ---==---(_)__  __ ____  __      pcg@goof.com
      --==---/ / _ \/ // /\ \/ /      http://schmorp.de/
      -=====/_/_//_/\_,_/ /_/\_\      XX11-RIPE
