From: "David S. Miller" <davem@redhat.com>
Subject: Re: Restrict local IP announcements in ARP requests
Date: Wed, 11 Feb 2004 20:22:51 -0800
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040211202251.7b05102c.davem@redhat.com>
References: <Pine.LNX.4.58.0402081149001.6268@u.domain.uli>
	<20040209140853.69ab8bea.davem@redhat.com>
	<Pine.LNX.4.58.0402100049470.1251@u.domain.uli>
	<20040209151053.1f63937a.davem@redhat.com>
	<Pine.LNX.4.58.0402100154010.1251@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0402100154010.1251@u.domain.uli>
List-Id: netdev.vger.kernel.org

On Tue, 10 Feb 2004 02:31:23 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> 	So, if hidden exists and is disabled it will not delay
> too much the processing but it is true that both arp_rcv and
> arp_solicit become more and more loaded with ugly checks.

The hidden patch does a hundred different things, that's what makes
it so undigestable. :)

Let us assume your arp_announce patch is applied.  Given that, plus the
things you've mentioned, only a tiny piece of functionality is
really needed from that hidden patch.

Why don't you extract out just the needed part, and toss together
an email with that patch explaining that specific behavior change?

Thanks.
