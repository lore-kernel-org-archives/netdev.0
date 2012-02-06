From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next V2] gro: introduce gro_mac_header_len
Date: Mon, 6 Feb 2012 12:01:13 -0800
Message-ID: <CAG4TOxNcB8+SP3f0WhZG1GZ481s+=7pVRv91vzAbwDzUZD8g_A@mail.gmail.com>
References: <CAG4TOxNgJ3=AFuA==Km815YzW8eQ7nD_UAzkXLSXcAyaCAAvPg@mail.gmail.com>
 <20120206.143230.1415707004934341114.davem@davemloft.net> <20120206.145148.558736903670696169.davem@davemloft.net>
 <20120206.145652.1575591691467905094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120206.145652.1575591691467905094.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 6, 2012 at 11:56 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> But this needs a little bit of work since the qdisc_skb_cb ends with a
> variable length array, but we can put an upper bound on this just like
> we do for skb->cb[] itself to fix this issue.
>
> I'll toss something together.

OK thanks.  We need something like 20 bytes of space to stash an
ipoib LL addr.  Which I guess leaves 28 bytes for sch use.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
