From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 00/13]: Netfilter IPsec support
Date: Wed, 23 Nov 2005 07:38:25 +0900 (JST)
Message-ID: <20051123.073825.106706639.yoshfuji@linux-ipv6.org>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
	<20051122.143438.84749134.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: davem@davemloft.net
In-Reply-To: <20051122.143438.84749134.davem@davemloft.net>
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

In article <20051122.143438.84749134.davem@davemloft.net> (at Tue, 22 Nov 2005 14:34:38 -0800 (PST)), "David S. Miller" <davem@davemloft.net> says:

> I want to do this so that Patrick doesn't have to repost
> 13 or so patches every time one of the parts still under
> discussion gets changed.
> 
> Actually, it seems the only part under discussion is how to
> avoid extension header reparsing and routing re-lookups on
> the ipv6 side.  That could be fixed by a follow-on patch and
> is not %100 necessary for initial integration in my opinion.
> 
> Can I get agreement on that?  Patrick sends me a dump of the
> current state of his patch set right now, we put that into
> net-2.6.16, and fix problems with followon patches.
> 
> Ok?

I believe he can manage these patches in his tree,
but anyway...

Well, it is very important to fix the packet processing
path issues (including the extension header issue)
before we merge it to the mainline. Definitely.
What I want to ensure is that they will not reach the mainline
tree without resolving those issues.

Thank you.

--yoshfuji
