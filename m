From: Emil Goode <emilgoode-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] batman-adv: Remove unused variable
Date: Wed, 06 Feb 2013 22:59:05 +0100
Message-ID: <1360187945.25903.5.camel@debian>
References: <1360168661-16871-1-git-send-email-emilgoode@gmail.com>
 <20130206172234.GB6008@ritirata.org> <1360173353.22154.4.camel@debian>
 <20130206195557.GC6008@ritirata.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org, lindner_marek-LWAfsSFWpa4@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20130206195557.GC6008-E/2OGukznS5g9hUCZPvPmw@public.gmane.org>
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

Hi Antonio,

If it is easier I can keep an eye on when the commit lands in the
net-next tree and then resend a modified version of the patch.
Or do you want me to resend it now?

Best regards, Emil

On Wed, 2013-02-06 at 20:55 +0100, Antonio Quartulli wrote:
> Hi Emil,
>=20
> On Wed, Feb 06, 2013 at 06:55:53 +0100, Emil Goode wrote:
> > Hi Antonio,
> >=20
> > The commit ed242d01 is in the linux-next tree and my patch depends on
> > that commit.
> >=20
>=20
> Yes, you are right. I was not aware of this commit, because the author
> did not CC us (neither netdev) even if he changed the code we maintain.
>=20
> As far as I can see that commit is in linux-next only.
> Therefore it must be applied there.
>=20
> However, I'd like you to change the commit message and write the full h=
ash of
> the commit you are referring to and its subject ("LIKE THIS"). This wou=
ld make
> it easier to find it.
>=20
>=20
> Regards,
>=20
> > Best regards, Emil
> >=20
> > On Wed, 2013-02-06 at 18:22 +0100, Antonio Quartulli wrote:
> > > Hi Emil,
> > >=20
> > > On Wed, Feb 06, 2013 at 05:37:41 +0100, Emil Goode wrote:
> > > > The commit ed242d01 removed a node parameter from iterators.
> > > > This patch removes a hlist_node struct that is no longer used.
> > > >=20
> > > > Sparse gives a warning:
> > > >=20
> > > > net/batman-adv/originator.c:411:21: warning:
> > > > 	unused variable =E2=80=98node_tmp=E2=80=99 [-Wunused-variable]
> > > >=20
> > > > Signed-off-by: Emil Goode <emilgoode-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > >=20
> > > On which tree did you base your patch?
> > > I cannot find the commit you are referring to (ed242d01) and the pa=
tch does not
> > > apply (neither on net nor net-next).
> > >=20
> > > Other than that the variable is used a couple of lines below (in th=
e code we
> > > have)...
> > >=20
> > > Regards,
> > >=20
> >=20
> >=20
>=20
