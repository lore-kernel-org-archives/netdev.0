From: Andi Kleen <ak@suse.de>
Subject: Re: possible bug in tcp_input.c
Date: Tue, 18 Nov 2003 15:01:22 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20031118150122.08d117f9.ak@suse.de>
References: <20031024162959.GB11154@louise.pinerecords.com.suse.lists.linux.kernel>
	<p73ptgma58b.fsf@oldwotan.suse.de>
	<20031118135805.GA9705@louise.pinerecords.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, grof@dragon.cz,
	davem@redhat.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Tomas Szepe <szepe@pinerecords.com>
In-Reply-To: <20031118135805.GA9705@louise.pinerecords.com>
List-Id: netdev.vger.kernel.org

On Tue, 18 Nov 2003 14:58:05 +0100
Tomas Szepe <szepe@pinerecords.com> wrote:

> On Oct-24 2003, Fri, 19:57 +0200
> Andi Kleen <ak@suse.de> wrote:
> 
> > > /* tcp_input.c, line 1138 */
> > > static inline int tcp_head_timedout(struct sock *sk, struct tcp_opt *tp)
> > > {
> > >   return tp->packets_out && tcp_skb_timedout(tp, skb_peek(&sk->write_queue));
> > > }
> > 
> > tp->packets_out > 0 implies that there is at least one packet in the write 
> > queue (it counts the number of unacked packets in flight, which are kept
> > in the write queue). When that's not the case something else is wrong.
> 
> Yes, that's exactly what davem said.  The corruption is happening somewhere
> in netsched/imq code that's not even part of the official kernel tree (and
> I'm told there's nobody to maintain the patch at present).

Ignore the mail. It was some machine flushing out an old mail queue
(with some very old mails from me that never made it out) 

I actually wrote it before DaveM if you check the dates ;-)

-Andi
