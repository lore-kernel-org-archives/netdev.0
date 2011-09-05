From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: install nf_nat.h and related headers to
 INSTALL_HDR_PATH
Date: Mon, 5 Sep 2011 19:48:47 +0200
Message-ID: <20110905174847.GB32733@1984>
References: <1315075784-10163-1-git-send-email-basile@opensource.dyc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net, blueness@gentoo.org,
	gurligebis@gentoo.org, base-system@gentoo.org, kernel@gentoo.org,
	toolchain@gentoo.org, mchehab@redhat.com, hverkuil@xs4all.nl,
	laurent.pinchart@ideasonboard.com, arnd@arndb.de,
	eparis@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org
To: "Anthony G. Basile" <basile@opensource.dyc.edu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1315075784-10163-1-git-send-email-basile@opensource.dyc.edu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 03, 2011 at 02:49:44PM -0400, Anthony G. Basile wrote:
> Currently nf_nat.h, nf_conntrack_tuple.h and related headers under
> include/net/netfilter are not installed as part of the public kernel
> headers.   However, there are userland applications, other than iptables
> which ships with its own headers, which need these to make use of NAT in
> the kernel's netfilter API.  For example, miniupnpd, requires them and is
> forced to search /usr/src/linux when building.

Could anyone clarify why miniupnpd (or any other application) require
this?

Those headers contain structure layouts that may change along time
without further notice, thus breaking backward compatibility.

and BTW, no need to cross-post this message to such a huge list of CC.
I guess you could simply use netfilter-devel for this.
