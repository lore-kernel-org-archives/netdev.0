From: James Corey <ploversegg@yahoo.com>
Subject: Re: 2.6.23-rc3 and SKY2 driver issue
Date: Mon, 20 Aug 2007 08:42:21 -0700 (PDT)
Message-ID: <370212.9287.qm@web90407.mail.mud.yahoo.com>
References: <20070816090556.6a5295e6@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760191AbXHTPmf@vger.kernel.org>
In-Reply-To: <20070816090556.6a5295e6@oldman>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Stephen Hemminger
<shemminger@linux-foundation.org> wrote:

> On Thu, 16 Aug 2007 10:25:45 +0200
> "Michal Piotrowski"
> <michal.k.k.piotrowski@gmail.com> wrote:
> 
> > [Adding Stephen and netdev to CC]
> > 
> > On 15/08/07, James Corey <ploversegg@yahoo.com>
> wrote:
> > >
> > > I tried running a D-link gig card on kernel
> 2.6.21.1
> > > and it came up fine, but when I did a sftp of
> > > an linux dvd ISO to it, the interface would lock
> > > up hard with the error
> > >
> > > eth1: hw csum failure.
> > >
> > > Call Trace:
> > >  <IRQ>  [<ffffffff804d3e31>]
> > > __skb_checksum_complete_head+0x46/0x5f
> > >  [<ffffffff804d3e56>]
> __skb_checksum_complete+0xc/0x11
> > >  [<ffffffff805046c7>] tcp_v4_rcv+0x157/0x810
> > >  [<ffffffff804d8a6f>] dev_queue_xmit+0x237/0x260
> > >  [<ffffffff80229990>]
> find_busiest_group+0x252/0x684
> > >  [<ffffffff804ead50>]
> ip_local_deliver+0xca/0x14c
> > >  [<ffffffff804eb24a>] ip_rcv+0x478/0x4ba
> > >  [<ffffffff803ec7d3>] sky2_poll+0x6f9/0x9b9
> > >  [<ffffffff8022bd5d>]
> > > run_rebalance_domains+0x13e/0x408
> > >  [<ffffffff804d877a>] net_rx_action+0xa8/0x166
> > >  [<ffffffff80235d62>] __do_softirq+0x55/0xc3
> > >  [<ffffffff8020a4ec>] call_softirq+0x1c/0x28
> > >  [<ffffffff8020b611>] do_softirq+0x2c/0x7d
> > >  [<ffffffff8020b8cf>] do_IRQ+0x13e/0x15f
> > >  [<ffffffff802086ce>] mwait_idle+0x0/0x46
> > >  [<ffffffff80209871>] ret_from_intr+0x0/0xa
> > >  <EOI>  [<ffffffff80208710>]
> mwait_idle+0x42/0x46
> > >  [<ffffffff80208666>] cpu_idle+0x8c/0xaf
> > >  [<ffffffff8078174e>] start_kernel+0x2ac/0x2b8
> > >  [<ffffffff80781140>] _sinittext+0x140/0x144
> > >
> > >
> > > So I tried running the latest snapshot
> 2.6.23-rc3
> > > and the almost the same thing happens. Only
> > > difference is that now the entire box locks up.
> > > The error is almost the same
> > >
> > > eth1: hw csum failure.
> > >
> > > Call Trace:
> > >  <IRQ>  [<ffffffff804779b6>]
> > > __skb_checksum_complete_head+0x43/0x56
> > >  [<ffffffff804779d5>]
> __skb_checksum_complete+0xc/0x11
> > >  [<ffffffff804a989d>] tcp_v4_rcv+0x14e/0x801
> > >  [<ffffffff8048ff84>]
> ip_local_deliver+0xca/0x14c
> > >  [<ffffffff80490472>] ip_rcv+0x46c/0x4ae
> > >  [<ffffffff880060f9>]
> :sky2:sky2_poll+0x72b/0x9c7
> > >  [<ffffffff8047c934>] net_rx_action+0xa8/0x166
> > >  [<ffffffff80235ced>] __do_softirq+0x55/0xc4
> > >  [<ffffffff8020c5cc>] call_softirq+0x1c/0x28
> > >  [<ffffffff8020d6fd>] do_softirq+0x2c/0x7d
> > >  [<ffffffff8020d9bb>] do_IRQ+0x13e/0x15f
> > >  [<ffffffff8020a780>] mwait_idle+0x0/0x48
> > >  [<ffffffff8020b951>] ret_from_intr+0x0/0xa
> > >  <EOI>  [<ffffffff880063e7>]
> > > :sky2:sky2_xmit_frame+0x0/0x41d
> > >  [<ffffffff8020a7c2>] mwait_idle+0x42/0x48
> > >  [<ffffffff8020a718>] cpu_idle+0xbd/0xe0
> > >  [<ffffffff80704a5a>] start_kernel+0x2ac/0x2b8
> > >  [<ffffffff80704140>] _sinittext+0x140/0x144
> > >
> > >
> > > I see that the new kernel includes some sort of
> > > SKY2 DEBUG stuff. I would be happy to rerun
> > > the test with that turned on, given some minor
> > > direction.
> > >
> > 
> > Regards,
> > Michal
> 
> Please reproduce with a more recent kernel?

Um, I thought 2.6.23rc WAS pretty recent. :-)

I'll check if there is something newer in the
repository now.

-J



       
____________________________________________________________________________________
Take the Internet to Go: Yahoo!Go puts the Internet in your pocket: mail, news, photos & more. 
http://mobile.yahoo.com/go?refer=1GNXIC
