From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: Route cache performance under stress
Date: Tue, 20 May 2003 14:55:10 +0300 (EEST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0305201451070.30255-100000@netcore.fi>
References: <20030520074352.N40831@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <sim@netnation.com>,
	<netdev@oss.sgi.com>, <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Jamal Hadi <hadi@shell.cyberus.ca>
In-Reply-To: <20030520074352.N40831@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

On Tue, 20 May 2003, Jamal Hadi wrote:
> On Tue, 20 May 2003, Pekka Savola wrote:
> > On Mon, 19 May 2003, Jamal Hadi wrote:
> > > I dont think the hashes are similar - its the effect into the
> > > slow path. I was told by someone who tested this on a priicey CISCO
> > > that they simply die unless capable of a feature called CEF.
> >
> > Yes, but pretty much nobody is using Cisco without CEF, except in the last
> > mile, low-end devices.
> >
> 
> so not a GSR thing only feature. At the edges though, wouldnt it be
> important to do more sexy things than just route based on a destination
> address?

Indeed.  For example, policy-based routing (e.g. source address dependent
routing) has been claimed to be in the CEF path now (previously it was in
the slow path), but I certainly would "like" to be shown wrong. :-)

By low-end edge devices I basically meant all DSL, ISDN, cablemodem etc.  
equipment.  I don't know of "midrange" Cisco gear, but basically
everything service providers use (at least 7xxx, 10xxx, and 12xxx series)  
do support CEF (or more complicated variations of it).

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings

