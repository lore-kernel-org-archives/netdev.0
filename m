From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 10/11] batman-adv: print OGM seq numbers
 as unsigned long
Date: Wed, 18 Apr 2012 03:28:04 -0400 (EDT)
Message-ID: <20120418.032804.800443379585204933.davem@davemloft.net>
References: <20120417.224746.802445483718191876.davem@davemloft.net>
	<20120418064659.GC27966@ritirata.org>
	<20120418070134.GD27966@ritirata.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20120418070134.GD27966-E/2OGukznS5g9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Date: Wed, 18 Apr 2012 09:01:35 +0200

> On Wed, Apr 18, 2012 at 08:47:00AM +0200, Antonio Quartulli wrote:
>> On Tue, Apr 17, 2012 at 10:47:46 -0400, David Miller wrote:
>> > From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
>> > Date: Tue, 17 Apr 2012 13:58:26 +0200
>> > 
>> > > OGM sequence numbers are declared as uint32_t and so they have to printed
>> > > using %u instead of %d in order to avoid wrong representations.
>> > > 
>> > > Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
>> > 
>> > Fix this commit message subject, "%u" is "unsigned int" not
>> > "unsigned long"
>> > 
>> > "unsigned long" would be "%lu"
> 
> There is a problem here. On my machine (x86_64) I have:
> 
> typedef unsigned int __u32;
> typedef         __u32           uint32_t;
> 
> 
> So I should use %u to print my uint32_t variable (as I reported in my commit
> message).
> 
> Probably this is not the case on each and every architecture?
> If so, how could I handle it?

The problem is not the patch, it's your commit message
you say "print ... as unsigned long", you're not printing
it as unsigned long, you're printing it as unsigned int.
