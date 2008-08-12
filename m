From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Tue, 12 Aug 2008 20:52:37 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808122044450.16105@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0808081256560.4551@wrl-59.cs.helsinki.fi>
 <20080811.144421.234396007.davem@davemloft.net> <200808120946.19459.thomas.jarosch@intra2net.com>
 <20080812.011822.155249871.davem@davemloft.net> <20080812144309.7d62fd86@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1560383134-1218563557=:16105"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>, sr@securenet.de,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080812144309.7d62fd86@tux>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1560383134-1218563557=:16105
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 12 Aug 2008, Dâniel Fraga wrote:

> On Tue, 12 Aug 2008 01:18:22 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > We had the same situation with ECN and window scaling, and my proposal
> > is the same as how we handled those situations involving broken
> > middleware boxes.
> 
> 	Sorry for my ignorance (I'm just an user), but if the problem
> is not with Linux, why this problem appeared just on 2.6.25 kernel? I
> mean, with 2.6.24 and before I never had stalled connections. Just a
> coincidence? Or something has changed in 2.6.25 which caused this?

I still propose that you tcpdump it, then I can tell you (I know
enough about Thomas' case but yours has a large number of
unknowns)... :-) I don't know why 2.6.24 didn't suffer from the
problem as FRTO was enabled already in it. The command you need
to create dump.log file:

# tcpdump -w dump.log -i <iface> host <peerip>

...you need root rights (or sudo) to do the capturing.


-- 
 i.
---696208474-1560383134-1218563557=:16105--
