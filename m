From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: Fix bugs in ip6ip6_tnl_xmit()
Date: Thu, 7 Aug 2003 21:32:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030807213259.56c953d5.davem@redhat.com>
References: <Pine.LNX.4.44.0308011353520.16201-100000@rhea.tcs.hut.fi>
	<Pine.LNX.4.44.0308051530560.30970-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0308051530560.30970-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 5 Aug 2003 16:42:32 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> There were two bugs in ip6ip6_tnl_xmit() which are fixed in this patch
> (made against Linux 2.6.0-test2 + cset 1.1612):
> 
> - ip6_tunnel must give its own getfrag function to ip6_append_data()
> - fix dst leakage when encapsulated packet too big

Patch applied, thank you Ville.
