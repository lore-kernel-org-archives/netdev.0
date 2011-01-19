From: Jesper Juhl <jj@chaosbits.net>
Subject: =?ISO-8859-7?Q?Re=3A_=5BPatch=5D_Kill_off_warning=3A_=A1inline=A2_is_not_at_beginning_of_declaration?=
Date: Wed, 19 Jan 2011 16:45:12 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1101191643070.15798@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1101170000270.13377@swampdragon.chaosbits.net>
	<alpine.LNX.2.00.1101191543110.26685@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-969819006-1295451912=:15798"
Cc: alsa-devel@alsa-project.org, Mauro Carvalho Chehab <mchehab@redhat.com>,
	Takashi Iwai <tiwai@suse.de>, Frederic Weisbecker <fweisbec@gmail.com>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	Jaroslav Kysela <perex@perex.cz>, Jens Axboe <jens.axboe@oracle.com>,
	Stephen Hemminger <shemminger@vyatta.com>, Andi Kleen <ak@linux.intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"Pekka Savola \(ipv6\)" <pekkas@netcore.fi>, x86@kernel.org,
	James Morris <jmorris@namei.org>, Ingo Molnar <mingo@redhat.com>,
	oprofile-list@lists.sf.net, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Mark Fasheh <mfasheh@suse.com>, Marcel Holtmann <marcel@holtmann.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Teigland <teigland@redhat.com>, Joel Becker <jlbec@evilplan.org>,
	Thomas Gleixner <tglx@linutronix.de>, linux-edac@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.ker
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <oprofile-list-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.LNX.2.00.1101191543110.26685@pobox.suse.cz>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/oprofile-list>,
	<mailto:oprofile-list-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=oprofile-list>
List-Post: <mailto:oprofile-list@lists.sourceforge.net>
List-Help: <mailto:oprofile-list-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/oprofile-list>,
	<mailto:oprofile-list-request@lists.sourceforge.net?subject=subscribe>
Errors-To: oprofile-list-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-969819006-1295451912=:15798
Content-Type: TEXT/PLAIN; charset=ISO-8859-7
Content-Transfer-Encoding: quoted-printable

On Wed, 19 Jan 2011, Jiri Kosina wrote:

> On Mon, 17 Jan 2011, Jesper Juhl wrote:
>=20
> > Fix a bunch of=20
> > 	warning: =A1inline=A2 is not at beginning of declaration
> > messages when building a 'make allyesconfig' kernel with -Wextra.
> >=20
> > These warnings are trivial to kill, yet rather annoying when building=
 with=20
> > -Wextra.
> > The more we can cut down on pointless crap like this the better (IMHO=
).
> >=20
> > A previous patch to do this for a 'allnoconfig' build has already bee=
n=20
> > merged. This just takes the cleanup a little further.
> >=20
> > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> > ---
> >  arch/x86/oprofile/op_model_p4.c |    2 +-
> >  drivers/bluetooth/btusb.c       |    4 ++--
> >  drivers/cpuidle/sysfs.c         |    2 +-
> >  drivers/edac/i7300_edac.c       |    2 +-
> >  fs/ocfs2/dir.c                  |    2 +-
> >  kernel/trace/ring_buffer.c      |    2 +-
> >  net/ipv6/inet6_hashtables.c     |    2 +-
> >  net/mac80211/tx.c               |    2 +-
> >  sound/pci/au88x0/au88x0.h       |    4 ++--
> >  sound/pci/au88x0/au88x0_core.c  |    4 ++--
> >  10 files changed, 13 insertions(+), 13 deletions(-)
> >=20
>
> Wow, what a huge CC list for such a simple change. Jesper, I think you=20
> should re-consider this next time. I bet you used get_maintainer script=
,=20
> didn't you? :)
>=20

Yes, I did. I wanted to be sure that everyone whoes code I was modifying=20
got the mail. I guess I should have broken it up into smaller pieces and=20
submitted them as a series instead.


> I have applied it to my tree now. If anyone has objections/has already=20
> applied part of the patch to subsystem tree, please let me know.
>=20

Thank you.

--=20
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

--8323328-969819006-1295451912=:15798
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Protect Your Site and Customers from Malware Attacks
Learn about various malware tactics and how to avoid them. Understand 
malware threats, the impact they can have on your business, and how you 
can protect your company and customers by using code signing.
http://p.sf.net/sfu/oracle-sfdevnl
--8323328-969819006-1295451912=:15798
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
oprofile-list mailing list
oprofile-list@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/oprofile-list

--8323328-969819006-1295451912=:15798--
