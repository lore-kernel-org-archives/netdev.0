From: James Morris <jmorris@redhat.com>
Subject: Re: [Coverity] Untrusted user data in kernel
Date: Fri, 17 Dec 2004 01:45:05 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0412170144410.12579-100000@thoron.boston.redhat.com>
References: <41C26DD1.7070006@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Bryan Fulton <bryan@coverity.com>, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41C26DD1.7070006@trash.net>
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

On Fri, 17 Dec 2004, Patrick McHardy wrote:

> James Morris wrote:
> 
> >This at least needs CAP_NET_ADMIN.
> >
> It is already checked in do_ip6t_set_ctl(). Otherwise anyone could
> replace iptables rules :)

That's what I meant, you need the capability to do anything bad :-)


- James
-- 
James Morris
<jmorris@redhat.com>
