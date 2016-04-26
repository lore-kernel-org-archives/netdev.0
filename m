From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH 4/5] batman-adv: Reduce refcnt of removed
	router when updating route
Date: Tue, 26 Apr 2016 17:00:28 +0200
Message-ID: <2064019.8u38J1EmDF@bentobox>
References: <1461641239-7097-1-git-send-email-a@unstable.cc>
 <1461641239-7097-5-git-send-email-a@unstable.cc>
 <83cedcb0-1090-2a0d-f3b8-c9c273c5f1d2@cogentembedded.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2136251.gcaumYK0xv";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Antonio Quartulli <a@unstable.cc>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <83cedcb0-1090-2a0d-f3b8-c9c273c5f1d2-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
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

--nextPart2136251.gcaumYK0xv
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Tuesday 26 April 2016 17:42:54 Sergei Shtylyov wrote:
> > _batadv_update_route rcu_derefences orig_ifinfo->router outside of a
> > spinlock protected region to print some information messages to the debug
> > log. But this pointer is not checked again when the new pointer is assigned
> > in the spinlock protected region. Thus is can happen that the value of
> 
>     Thus is can? :-)

Yes, my fault. s/is/it/.

[...]
> >  	spin_lock_bh(&orig_node->neigh_list_lock);
> > +	/* curr_router used earlier may not be the current orig_ifinfo->router
> > +	 * anymore because it was dereferenced outside of the neigh_list_lock
> > +	 * protected region. After the new best neighbor has replace the current
> 
>     Replaced.
> 
> [...]

This one looks like one of Marek's modifications [1] to the patch. But I would
guess that he has nothing against adding a 'd'.

Should Antonio resent all the patches or is a different approach preferred?

Kind regards,
	Sven

[1] https://patchwork.open-mesh.org/patch/15940/

--nextPart2136251.gcaumYK0xv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXH4KMAAoJEF2HCgfBJntGoI8QAK60kshq51kVNBA1HJ8NiNPc
ejjbAB/0sbi1JR75+VpCf8cD1BBV84jDRbChOLtJaVw7HTg2vBl1EC6n24FUhDfQ
1ylNxYoVHX7ncef03FCmZgQX4e7mvnzI4wBerpNhQm7oj4ivJN5n3lyy0z6b6BUT
RJ+7aJ0Sc1aikiAy+wL3GqS5GI3ucvqXM125QpiO8QpHKV3qjnxM7iOXr854Xlkh
R7pigWG3ZkIyzfn5Qokywbb2rJUy/6HQW1DBk6y2Qv4PSRxYLvo6WP1wsLWVKd5p
KWc52Z+QkSi8Rt5ZnP4Q4DkZAYcVIcH8cQel9kyOO3FDUGwj5nVaBZJ7eK8SnKYf
EyTaaQ0HSfnBlzcV/adg0ShoRYyEGff0nUTDegXxpzKzw8mWHKJOxKNwg7+MHUkl
67znfxZguDCZvMd/jWD0bajc8AUr4JPLolxYBqkZW7mnlezLXd6pyAuJlwEqqD98
w4yOWWCl0f17DLifQk2Lp2+geqF1D4/zqRFEIF1xc6hVVYtSncxEvygmJ94KpBCG
9MEXQGMxlsXDxWEkk3Fw7uLiYo+IdWJCtPV6JooTYW2gcFsH7PBb2/Fg67OpLRnB
ZpDvbRWHdlsMchRZsZxQzjMov90R042RS/cMBFGPRltD7QgAMl0q1QcKzcmPCRpt
ZVrLoe6svtCbX5Z0J1z8
=MIlJ
-----END PGP SIGNATURE-----

--nextPart2136251.gcaumYK0xv--
