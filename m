From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: Odd use of %14pM in
 net/batman-adv/distributed-arp-table.c
Date: Wed, 14 Jun 2017 02:32:16 -0700
Message-ID: <1497432736.18751.39.camel@perches.com>
References: <1497390701.18751.26.camel@perches.com>
 <5300874.nPgxNW8UST@bentobox>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Antonio Quartulli <a@unstable.cc>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <5300874.nPgxNW8UST@bentobox>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Wed, 2017-06-14 at 10:23 +0200, Sven Eckelmann wrote:
> On Dienstag, 13. Juni 2017 14:51:41 CEST Joe Perches wrote:
> > An output mac address is 17 bytes
> 
> [...]
> > but in net/batman-adv/distributed-arp-table.c
> 
> [...]
> > %14pM is odd as this should not emit the last byte of the
> > mac address.  So given the example above, it would output
> > 00:11:22:33:44
> 
> [...]
> 
> I completely agree too the "wrong length" part. It is currently not omitting 
> the last byte:

Right, I only looked at vsprintf.c and mistook precision for
field_width.

Do you want to provide a patch to convert it to simple %pM's?

OK.
