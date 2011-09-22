From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 6/7] tcp buffer limitation: per-cgroup limit
Date: Thu, 22 Sep 2011 12:58:03 +0300
Message-ID: <20110922095803.GA4530@shutemov.name>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com>
 <1316393805-3005-7-git-send-email-glommer@parallels.com>
 <CAHH2K0Yuji2_2pMdzEaMvRx0KE7OOaoEGT+OK4gJgTcOPKuT9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org,
	paul@paulmenage.org, lizf@cn.fujitsu.com,
	kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com,
	davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <CAHH2K0Yuji2_2pMdzEaMvRx0KE7OOaoEGT+OK4gJgTcOPKuT9g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 21, 2011 at 11:01:46PM -0700, Greg Thelen wrote:
> On Sun, Sep 18, 2011 at 5:56 PM, Glauber Costa <glommer@parallels.com> =
wrote:
> > +static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
> > +{
> > + =A0 =A0 =A0 return (mem =3D=3D root_mem_cgroup);
> > +}
> > +
>=20
> Why are you adding a copy of mem_cgroup_is_root().  I see one already
> in v3.0.  Was it deleted in a previous patch?

mem_cgroup_is_root() moved up in the file.

--=20
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
