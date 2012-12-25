From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: Re: [PATCH 1/7] batman-adv: Move soft-interface
	initialization to ndo_init
Date: Tue, 25 Dec 2012 16:19:17 +0800
Message-ID: <201212251619.17912.lindner_marek@yahoo.de>
References: <1353715332-4284-1-git-send-email-sven@narfation.org>
 <201212250337.48595.lindner_marek@yahoo.de>
 <CANiGF9_4QP0ts2kV9Bruk_8L7h1870LMcrRhtsYu35q=COF0hQ@mail.gmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Pau Koning <paukoning-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <CANiGF9_4QP0ts2kV9Bruk_8L7h1870LMcrRhtsYu35q=COF0hQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Tuesday, December 25, 2012 07:18:37 Pau Koning wrote:
> >> What decision? I only see something about Patch 6 and Patch 7: Antonio
> >> Quartulli doesn't want rtnetlink support in batman-adv. I don't see
> >> any other statement about the rest of the patchset.
> > 
> > Quoting Antonio:
> > 
> > 
> > Anyway, I discussed about this together with the others and it seems
> > that a proper solution now is to wait before merging this patchset and
> > fix the current sysfs/rtnl_lock problem first. What do you think?
> > 
> > Adding a new API without fixing the current one doesn't sound like a good
> > move.
> > <<<
> > 
> > What isn't clear ?
> 
> AFAIK patch 6 and 7 are the "new" rtnetlink API. The rest can be
> categorized as fixes for bugs and for the wrong way to implementation
> things.

After looking at the patches again, I'd say only patch1 & patch2 could be 
categorized as "fixes" while the remaining patches are preparation patches for 
the netlink stuff which is added in the last step. Whether patch1 & patch2 
actually fix problems batman-adv already has today or whether they are 
necessary once you use netlink is unclear to me. If they are unrelated to this 
patchset they'd be sent separately, wouldn't they ?

Cheers,
Marek
