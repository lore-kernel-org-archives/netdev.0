From: Lars Marowsky-Bree <lmb@suse.de>
Subject: Re: [PATCH 2.6] iptables CLUSTERIP target
Date: Thu, 21 Oct 2004 15:33:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021133346.GL3911@marowsky-bree.de>
References: <20041020223828.GP19899@sunbeam.de.gnumonks.org> <20041021075530.GA1278@infradead.org> <20041021091229.GA3551@sunbeam.de.gnumonks.org> <20041021110513.GA21579@outpost.ds9a.nl> <20041021130327.GD3551@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>, bert hubert <ahu@ds9a.nl>,
        Christoph Hellwig <hch@infradead.org>,
        Linux Netdev List <netdev@oss.sgi.com>
Content-Disposition: inline
In-Reply-To: <20041021130327.GD3551@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 2004-10-21T15:03:27, Harald Welte <laforge@netfilter.org> wrote:

> > I note with glee that CLUSTERIP implements (and improves) the evil id=
eas of
> > http://lartc.org/autoloadbalance.php3
>=20
> I didn't know about that page, but yes, indeed.  I first was informed
> about this approach by Fabio Olive Leite, who was one of my colleagues
> at Conectiva (where I was 2001).  He presented this approach at the
> Linux Kongress 2002:
> http://www.linux-kongress.org/2002/papers/lk2002-leite.html
>=20
> Later SuSE approached me if I was interested in implementing that idea,
> and that's how CLUSTERIP happened.  If I'm not mistaken SuSE is already
> shipping this (at least in some beta version?) - I don't really know bu=
t
> maybe lmb can shed some light on this issue.

Yeah, I learned about it from Fabio, thought it would be a cool idea,
and eventually we sponsored Harald to make it happen. It's shipping in
SLES9, and we're adding full support for it in the 2.0 heartbeat cluster
resource manager.=20

It's meant to complement the LVS / mod_backhand based approaches.

If the proc file IO for communicating with the module goes away in
favour of a commandline based add/list/remove/etc interface, that would
just help to tidy up our code, so it's OK with me.

> > And yes, I've received hate mail over this from switch engineers :-)
> Why is that?  They have to deal with multicast traffic, too...  and I
> don't really see how this is any different.

Yeah, but with this they get a whole lot more ;-)


Sincerely,
    Lars Marowsky-Br=E9e <lmb@suse.de>

--=20
High Availability & Clustering
SUSE Labs, Research and Development
SUSE LINUX AG - A Novell company
