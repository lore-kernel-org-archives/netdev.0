From: Manuel Schoelling <manuel.schoelling@gmx.de>
Subject: Re: [PATCH] xilinx: Fix compiler warning
Date: Sun, 22 Jun 2014 13:23:34 +0200
Message-ID: <1403436214.26292.4.camel@schoellingm.dzne.de>
References: <1403432461-18296-1-git-send-email-manuel.schoelling@gmx.de>
	 <53A6BAC5.80206@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: michal.simek@xilinx.com, anirudh@xilinx.com, John.Linn@xilinx.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53A6BAC5.80206@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On So, 2014-06-22 at 15:15 +0400, Sergei Shtylyov wrote:
> Hello.
>=20
> On 06/22/2014 02:21 PM, Manuel Sch=C3=B6lling wrote:
>=20
> > The time comparsion functions require arguments of type unsigned lo=
ng
> > instead of (signed) long.
>=20
> > Signed-off-by: Manuel Sch=C3=B6lling <manuel.schoelling@gmx.de>
>=20
> [...]
>=20
> > diff --git a/init/do_mounts.c b/init/do_mounts.c
> > index 60c4196..2d069a3 100644
> > --- a/init/do_mounts.c
> > +++ b/init/do_mounts.c
> > @@ -351,7 +351,6 @@ static void __init get_fs_names(char *page)
> >   				continue;
> >   			line++;
> >
> > -			/* append fsname */
> >   			memmove(fsnames, line, strlen(line)+1);
> >   			fsnames +=3D strlen(fsnames)+1;
> >   		} while (page !=3D NULL);
> >
>=20
>    Seems like unrelated random change.
Thanks, you are right: somehow this change made it into my patch.
Probably I was not careful enough when using 'git commit -a'.

Sorry, I will resend a fixed patch in a second.

>=20
> WBR, Sergei
>=20
