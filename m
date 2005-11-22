From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 00/13]: Netfilter IPsec support
Date: Tue, 22 Nov 2005 14:34:38 -0800 (PST)
Message-ID: <20051122.143438.84749134.davem@davemloft.net>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
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

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 20 Nov 2005 17:31:28 +0100

> This is the latest netfilter/IPsec patchset. Its purpose is to make
> IPsec look as much as a normal tunnel device to netfilter as possible
> and to enable NAT support.

I think there are some of these patches that we can merge in
right now into net-2.6.16...

I want to do this so that Patrick doesn't have to repost
13 or so patches every time one of the parts still under
discussion gets changed.

Actually, it seems the only part under discussion is how to
avoid extension header reparsing and routing re-lookups on
the ipv6 side.  That could be fixed by a follow-on patch and
is not %100 necessary for initial integration in my opinion.

Can I get agreement on that?  Patrick sends me a dump of the
current state of his patch set right now, we put that into
net-2.6.16, and fix problems with followon patches.

Ok?
