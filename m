From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] net/sched/em_canid: Ematch rule to match CAN frames
 according to their CAN IDs
Date: Wed, 13 Jun 2012 08:18:28 -0400
Message-ID: <20120613121828.GP28598@canuck.infradead.org>
References: <1339508913-7784-1-git-send-email-lisovy@gmail.com>
 <1339509809.22704.149.camel@edumazet-glaptop>
 <1339511593.22704.157.camel@edumazet-glaptop>
 <1339512622.8536.3.camel@lolumad>
 <4FD76349.6040407@hartkopp.net>
 <878vfr7d4l.fsf@steelpick.2x.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Rostislav Lisovy <lisovy@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, lartc@vger.kernel.org,
	pisa@cmp.felk.cvut.cz
To: Michal Sojka <sojkam1@fel.cvut.cz>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <878vfr7d4l.fsf@steelpick.2x.cz>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 13, 2012 at 11:52:10AM +0200, Michal Sojka wrote:
> The performance of ematch might be slightly lower than of standalone
> classifier. Rosta will compare the performance soon. 

I think it doesn't make a difference, there is no additional locking
involved. Numbers definitely welcome though.

> > E.g. is it still possible to add additional ematches like checking for
> > patterns inside can_frame.data[] (which is located in skb->data) with
> > ematch_u32 or e.g. ematch_text ??
> 
> AFAIK, this should be possible and it will be a big advantage over
> implementation as a standalone classifier.

Definitely and the real advantage is that you can combine these
using logic operators.
