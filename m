From: Michael Buesch <mbuesch-KuiJ5kEpwI6ELgA04lAiVw@public.gmane.org>
Subject: Re: Broadcom 43xx first results
Date: Mon, 5 Dec 2005 21:23:42 +0100
Message-ID: <200512052123.42357.mbuesch@freenet.de>
References: <E1Eiyw4-0003Ab-FW@www1.emo.freenet-rz.de> <20051205190038.04b7b7c1@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3505332.8KX3vdio57";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
   NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
In-Reply-To: <20051205190038.04b7b7c1-IhiK2ZEFs2oCVLCxKZUutA@public.gmane.org>
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

--nextPart3505332.8KX3vdio57
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 05 December 2005 19:00, you wrote:
> On Sun, 04 Dec 2005 19:50:08 +0100, mbuesch-KuiJ5kEpwI6ELgA04lAiVw@public.gmane.org wrote:
> > The team is in the progress of writing a SoftwareMAC layer,
> > which is needed for the bcm device. The SoftMAC is still very
> > incomplete. So do not expect to do any fancy stuff like WPA
> > or something line that with it.
>=20
> Why yet another attempt to write 802.11 stack? Sure, the one currently
> in the kernel is unusable and everybody knows about it. But why not to
> improve code opensourced by Devicescape some time ago instead of
> inventing the wheel again and again? Yes, I know that code is not
> perfect and needs a lot of work, but it is the best piece of code we
> have available now. And it _does_ support WPA and such - in fact, it is
> nearly complete.

This is __not__ "yet another stack". It is an _extension_.
It is all about management frames, which the in-kernel code
does not manage.

We want a working device. The driver is in a state where it
is more or less usable. What is missing, is code to handle
management.
We tried the code from the RTL driver, but it is total crap.
We dropped it again. We thought about using yet another out of
kernel ieee80211 stack, but we began to write an extension
to the in-kernel code. If that was right or wrong, well, that's
the question.

If you _really_ think we should have used $EXTERNAL_STACK,
go and patch the driver to work with it. I would really like
to see it working. It is easy to change the used 80211 stack,
as it is only a task of replacing TX and RX function calls
(and a few parameter settings to the ieee struct on init).

PS: I forgot to mention in the announcement, that the driver has
problems with OFDM (that are all 802.11g) rates. So use 802.11b
rates. 11MBit works fine.

=2D-=20
Greetings Michael.

--nextPart3505332.8KX3vdio57
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBDlKHOlb09HEdWDKgRAusHAKCo/UiGD0uml9kBufhMV/ihfbz/NwCfcaJO
brDR+BsW08FI8T6H4BWVeFE=
=H+BS
-----END PGP SIGNATURE-----

--nextPart3505332.8KX3vdio57--
