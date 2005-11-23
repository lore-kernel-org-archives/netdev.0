From: Robert Iakobashvili <coroberti@gmail.com>
Subject: Re: Netlink send from the interrupt context
Date: Wed, 23 Nov 2005 10:33:49 +0200
Message-ID: <7e63f56c0511230033w68e60863wb8a026df3eea3077@mail.gmail.com>
References: <7e63f56c0511210034h49917721k74ddb251b9bb1815@mail.gmail.com>
	<00a901c5ee79$389e5040$6704a8c0@skqianyi>
	<7e63f56c0511222328w6368f7bcl7877fe3aa62c2807@mail.gmail.com>
	<02e501c5f002$e5094d00$6704a8c0@skqianyi>
	<7e63f56c0511230004j79c7f080j56e25251387ebe94@mail.gmail.com>
	<031201c5f007$0ce2e1c0$6704a8c0@skqianyi>
	<7e63f56c0511230032x5097569dr3ddac4b05bb6019c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Yu Zhiguo <yuzg@nanjing-fnst.com>
In-Reply-To: <7e63f56c0511230032x5097569dr3ddac4b05bb6019c@mail.gmail.com>
Content-Disposition: inline
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

On 11/23/05, Robert Iakobashvili <coroberti@gmail.com> wrote:
> On 11/23/05, Yu Zhiguo <yuzg@nanjing-fnst.com> wrote:
> > Please refer to the function netlink_broadcast(),
> >    int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid=
, u32 group, int allocation)
> > I think if allocation=3DGFP_ATOMIC, it can be used in interrupt context=
.
> > What's your opinion?

Allocation is OK and it uses only spinlocks in all functions called,
no semaphores.

My concern actually rises from here:
http://www.ussg.iu.edu/hypermail/linux/kernel/0407.3/0455.html

Sincerely,
----------------------------------------------------------------
Robert Iakobashvili  - NAVIGARE NECESSE EST
coroberti at gmail dot com
---------------------------------------------------------------
