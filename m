From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Fw: Re: [PATCH] (6/6) ipvs -- get rid of skb_linearize
Date: Tue, 23 Sep 2003 01:53:52 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309230139370.1634-100000@u.domain.uli>
References: <20030922145239.976AE2C244@lists.samba.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>,
        Stephen Hemminger <shemminger@osdl.org>,
        Wensong Zhang <wensong@linux-vs.org>,
        <lvs-users@LinuxVirtualServer.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20030922145239.976AE2C244@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 23 Sep 2003, Rusty Russell wrote:

> > better the following stuff to be included now. Rusty, Dave? Is
> > someone willing to review this before inclusion?
>
> Sure...
>
> > http://www.ssi.bg/~ja/ipvs-2.6.0-test2/readme.txt
>
> > - at least struct iphdr in first fragment, not shared
> >
> > - ip_defrag is already called, so ip_send_check is still needed
> >
> > - then we add all needed checks for read and write access and extending
> > the first fragment
>
> Alexey's advice was not to pull packets we don't modify, but use
> skb_copy_bits, and use skb_ip_make_writable() where we do modify.
> This means that you don't have to care about shared or cloned skbs, it
> makes your intentions explicit, and it's more future-proof.
>
> It's more invasive, but my experience with doing netfilter_ipv4 was
> that it made things much neater when finished.  It helps to get rid of
> lots of the temporary variables, too, I've found (too easy to forget
> to update them).

	Ok, thank you Rusty! We will need some time to check the
changes...

Regards

--
Julian Anastasov <ja@ssi.bg>
