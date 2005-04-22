From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [RFC INTRO 0/5] H-TCP congestion control
Date: Fri, 22 Apr 2005 04:15:10 +0100
Message-ID: <20050422031510.GA13508@mail.shareable.org>
References: <20050311160734.30424.67955.65942@galon.ev-en.org> <20050311094239.4c59c29d@dxpl.pdx.osdl.net> <426849C2.7000409@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	"David S.Miller" <davem@davemloft.net>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com, Douglas Leith <doug.leith@nuim.ie>
Return-path: <linux-net-owner@vger.kernel.org>
To: Baruch Even <baruch@ev-en.org>
Content-Disposition: inline
In-Reply-To: <426849C2.7000409@ev-en.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Baruch Even wrote:
> >>This patch is covered by a pending patent, a license is being worked on to
> >>enable the inclusion in Linux. Comments and suggestions on this are also
> >>solicited.
> >
> >
> >Has this changed?
> 
> This has changed now. The code is now released under the GNU GPL v2, 
> according to what I was told this effectively implies that any patent 
> right that the university will have regarding this technology is 
> effectively licensed for use with this code.
> 
> Please let me know if there is anything else that we need to do to let 
> the review and possible inclusion of our contribution to proceed.

The patents must be licensed for _all_ GPL v2 implementations of that
algorithm, not just in this specific code.  (And it would be
friendlier if you granted a patent license for GPL v2 and later).

That's because it's necessary for derivative works to have the patent
license too, and derivative works includes taking the code and totally
rewriting it for a different operating system or a different
application.

Otherwise, section 7 of the GPL kicks in, and although you the authors
could distribute the code, nobody could _redistribute_ it because they
couldn't satisfy the requirements of section 7.

Also, just because you, the authors, are distributing the code under
GPLv2, that doesn't automatically grant a patent license (unless
that's the university's policy).  The GPL does _not_ state that you
grant patent licenses by distributing the program.  Rather, it
_forbids_ redistributing the code if a patent license does not permit
royalty-free distribution by all those who receive copies directly or
indirectly, and that's the situation in the absence of a patent
license being granted.  You, as the authors, are exempt simply by
being the copyright holders and therefore not bound by the GPL terms
applying to your own code.

-- Jamie
