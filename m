From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/4] deferred drop, __parent workaround, reshape_fail
Date: 16 Aug 2004 09:00:35 -0400
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <1092661235.2874.71.camel@jzny.localdomain>
References: <411C0FCE.9060906@crocetta.org>
	 <1092401484.1043.30.camel@jzny.localdomain>
	 <20040816072032.GH15418@sunbeam2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: sandr8@crocetta.org, devik@cdi.cz, netdev@oss.sgi.com,  netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040816072032.GH15418@sunbeam2>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Mon, 2004-08-16 at 03:20, Harald Welte wrote:

> On Fri, Aug 13, 2004 at 08:51:24AM -0400, jamal wrote:
> > Alessandro,
> > 
> > This summary applies to all your patches: Too many changes that seem
> > unnecessary. Take a deep breath.
> 
> I'm actually not as pessimistic about all his changes.
> 
> Allesandro's ultimate goal seems to be connection-based accounting that
> accounts precisely which packets have actually hit the outgoing wire.
> While I'm quite happy with the now in-kernel conntrack accounting
> (basedo on Rx rather than Tx packets/bytes), this is a different
> definition of accounting.

When did that code go in?

> Let's discuss the individual patches seperately.
> 
> 1) Is certainly not a huge issue, no debate here

Although the patch does look innocent,
actually it may break a lot of things since that code is particulary
tricky and the patch changes the environmental rules. It needs study.
since it doesnt add anything other than cosmetics, holding on it
might be the wisest thing.

> 2) I am not as familiar with the tc/scheduler code as you are, but I
> also think that what he is trying to achieve is a valid goal.  He tries
> to make all tc-related packet drops go to a single code path for packet
> dropping.  Independent of Allesandro's implementation, I would really
> like to see something like this.   We once had an experimental patch
> called the 'dropped hook' that would be traversed for all packets
> dropped somewhere in the stack (for auditing in userspace, whatever).
> Having a single packet drop point makes such a change less intrusive.

Seems to me the interest is more having single point for stats
collection.
Let me think about it for a bit and get back to you guys.

> 3) Is already in davem's tree, no need for discusion ;)

Didnt know that ;-> Is it in released kernels already?
Actually that patch should be fine.

> 4) This is the part you are complaining about, right?  I agree, I don't
> like conntrack specific stuff in dev.c and packet scheduler areas.

Let me think about it and get back to you. Solution to #2 should apply
here.

cheers,
jamal
