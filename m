From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] reduce netfilte sk_buff enlargement
Date: Tue, 19 Jul 2005 00:23:43 -0700 (PDT)
Message-ID: <20050719.002343.26274916.davem@davemloft.net>
References: <20050717220451.GB13434@rama.risq.ericsson.ca>
	<20050718.203145.105430424.davem@davemloft.net>
	<Pine.LNX.4.61.0507190916410.15134@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, wensong@linux-vs.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: jengelh@linux01.gwdg.de
In-Reply-To: <Pine.LNX.4.61.0507190916410.15134@yvahk01.tjqt.qr>
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

From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Date: Tue, 19 Jul 2005 09:18:38 +0200 (MEST)

> >but for now I'll eat that one-bit member.
> 
> What is more important? Being as small as possible using bitfields, or being 
> as fast as possible? (Usage of bitfields is some CPU overhead for their 
> extraction)

I'm conjuring that we can store the state elsewhere, for example
in the SKB ->cb[] control block.  But that requires some verifications.

Memory access overhead dwarfs whatever the cpu has to do to extract
the bits.
