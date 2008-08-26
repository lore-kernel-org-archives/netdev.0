From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Tue, 26 Aug 2008 17:32:20 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808261731120.4551@wrl-59.cs.helsinki.fi>
References: <20080819213417.45133573@tux> <Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
 <20080822183224.2d52f16c@tux> <20080822.143709.65615512.davem@davemloft.net>
 <20080823111446.06a350a2@tux> <Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
 <20080824163843.33b4f890@tux> <Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="-696208474-1103248658-1219647395=:27330"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel_Fraga?=" <fragabr@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0808261731121.4551@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1103248658-1219647395=:27330
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0808250957371.27330@wrl-59.cs.helsinki.fi>

On Tue, 26 Aug 2008, Ilpo Järvinen wrote:

> ListenOverflows might explain this (it can't be ListenDrops since it's 
> equal to ListenOverflows and both get incremented on overflow). Are you 
> perhaps short on workers at the userspace server? It would be nice to 
> capture those mibs often enough (eg., once per 1s with timestamps) during 
> the stall to see what actually gets incremented during the event because 
> there's currently so much haystack that finding the needle gets impossible 
> (ListenOverflows 47410) :-). Also, the corresponding tcpdump would be 
> needed to match the events.

Alternatively, you could strace the userspace to see that it keeps 
accept()'ing the connections.

-- 
 i.
---696208474-1103248658-1219647395=:27330--
