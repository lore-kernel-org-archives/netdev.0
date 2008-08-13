From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Wed, 13 Aug 2008 21:34:10 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808132108480.18807@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0808081256560.4551@wrl-59.cs.helsinki.fi>
 <20080811.144421.234396007.davem@davemloft.net> <200808120946.19459.thomas.jarosch@intra2net.com>
 <20080812.011822.155249871.davem@davemloft.net> <20080812144309.7d62fd86@tux>
 <Pine.LNX.4.64.0808122044450.16105@wrl-59.cs.helsinki.fi> <20080813145310.0c1e534c@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1465421246-1218652450=:18807"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>, sr@securenet.de,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080813145310.0c1e534c@tux>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1465421246-1218652450=:18807
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 13 Aug 2008, Dâniel Fraga wrote:

> On Tue, 12 Aug 2008 20:52:37 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > I still propose that you tcpdump it, then I can tell you (I know
> > enough about Thomas' case but yours has a large number of
> > unknowns)... :-) I don't know why 2.6.24 didn't suffer from the
> > problem as FRTO was enabled already in it. The command you need
> > to create dump.log file:
> > 
> > # tcpdump -w dump.log -i <iface> host <peerip>
> > 
> > ...you need root rights (or sudo) to do the capturing.
> 
> 	Ok, but the problem is that the bug doesn't happen
> frequently... yesterday I waited for it to happen and nothing
> happened :). I'll keep watching it... if I can get the dump, I send it.

Ok, thanks for your efforts... These are often hard to reproduce because
some not that likely pattern needs to happen and such things is often not
easily controllable (if it is at all possible to influence the 
likelyhoods).

-- 
 i.
---696208474-1465421246-1218652450=:18807--
