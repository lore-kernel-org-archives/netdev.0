From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Tue, 17 Mar 2009 13:10:47 -0400
Message-ID: <20090317171047.GF6737@tuxdriver.com>
References: <1237143683.24621.7.camel@johannes.local> <20090315202603.GA9077@elte.hu> <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com> <alpine.LFD.2.00.0903161250080.3082@localhost.localdomain> <b6a2187b0903161655q15437156qc926c8db37d8ba4b@mail.gmail.com> <20090317144802.GF3549@tuxdriver.com> <20090317152801.GA6737@tuxdriver.com> <20090317153924.GA21061@elte.hu> <20090317160527.GB6737@tuxdriver.com> <b6a2187b0903170924u72723220x4c0a717e3cfebf8d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jeff Chua <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <b6a2187b0903170924u72723220x4c0a717e3cfebf8d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 18, 2009 at 12:24:33AM +0800, Jeff Chua wrote:
> On Wed, Mar 18, 2009 at 12:05 AM, John W. Linville <linville@tuxdrive=
r.com>
> > the reverts. =A0But if you think it is helpful:
> > =A0 =A0 =A0 =A0http://bugzilla.kernel.org/attachment.cgi?id=3D20567=
&action=3Dview
>=20
> I tried applying the above patch against the latest linux git
> (18439c39e826191c0ef08c3a3271ce7ece46a860), but got a lot of rejects.
> Is this supposed to be?
>=20
>=20
> patch -p1 </tar/v2.6/revert-remove-ssid-knowledge-from-driver-series.=
patch
> 1 out of 1 hunk FAILED -- saving rejects to file
> drivers/net/wireless/adm8211.h.rej
> 1 out of 2 hunks FAILED -- saving rejects to file
> drivers/net/wireless/b43/main.c.rej
> 1 out of 2 hunks FAILED -- saving rejects to file
> drivers/net/wireless/b43legacy/main.c.rej
> 1 out of 1 hunk FAILED -- saving rejects to file
> drivers/net/wireless/iwlwifi/iwl-3945.h.rej
> 3 out of 4 hunks FAILED -- saving rejects to file
> drivers/net/wireless/iwlwifi/iwl-agn.c.rej
> 1 out of 1 hunk FAILED -- saving rejects to file
> drivers/net/wireless/iwlwifi/iwl-dev.h.rej
> 3 out of 5 hunks FAILED -- saving rejects to file
> drivers/net/wireless/iwlwifi/iwl3945-base.c.rej
> 1 out of 3 hunks FAILED -- saving rejects to file include/net/mac8021=
1.h.rej

Works for me...I even re-downloaded the patch from bugzilla.

/home/linville/git/linux-2.6
[linville-t400.local]:> git show
commit 18439c39e826191c0ef08c3a3271ce7ece46a860
Merge: 9e8912e... b35f8ca...
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Tue Mar 17 08:59:33 2009 -0700

    Merge git://git.kernel.org/pub/scm/linux/kernel/git/agk/linux-2.6-d=
m
   =20
    * git://git.kernel.org/pub/scm/linux/kernel/git/agk/linux-2.6-dm:
      dm crypt: wait for endio to complete before destruction
      dm crypt: fix kcryptd_async_done parameter
      dm io: respect BIO_MAX_PAGES limit
      dm table: rework reference counting fix
      dm ioctl: validate name length when renaming


/home/linville/git/linux-2.6
[linville-t400.local]:> patch -p1 < revert-remove-ssid-knowledge-from-d=
river-series.patch=20
patching file drivers/net/wireless/adm8211.c
patching file drivers/net/wireless/adm8211.h
patching file drivers/net/wireless/b43/main.c
patching file drivers/net/wireless/b43legacy/main.c
patching file drivers/net/wireless/iwlwifi/iwl-3945.h
patching file drivers/net/wireless/iwlwifi/iwl-agn.c
patching file drivers/net/wireless/iwlwifi/iwl-dev.h
patching file drivers/net/wireless/iwlwifi/iwl-scan.c
patching file drivers/net/wireless/iwlwifi/iwl3945-base.c
patching file include/net/mac80211.h
patching file net/mac80211/ieee80211_i.h
patching file net/mac80211/main.c
patching file net/mac80211/mlme.c
patching file net/mac80211/wext.c

Perhaps you have a dirty tree?

	git checkout -f

Does that help?

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
