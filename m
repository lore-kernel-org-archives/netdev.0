From: Henrik Austad <henrik@austad.us>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Mon, 20 Jun 2016 11:06:56 +0200
Message-ID: <20160620090656.GB8011@sisyphus.home.austad.us>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain>
 <20160613195136.GC2441@netboy>
 <20160614121844.54a125a5@lxorguk.ukuu.org.uk>
 <5760C84C.40408@sakamocchi.jp>
 <20160615080602.GA13555@localhost.localdomain>
 <5764DA85.3050801@sakamocchi.jp>
 <20160618224549.GF32724@icarus.home.austad.us>
 <5766B01B.9070903@sakamocchi.jp>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6674882102356082472=="
Cc: netdev@vger.kernel.org, Richard Cochran <richardcochran@gmail.com>,
 linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
 Arnd Bergmann <arnd@linaro.org>
To: Takashi Sakamoto <o-takashi@sakamocchi.jp>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <5766B01B.9070903@sakamocchi.jp>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org


--===============6674882102356082472==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tsOsTdHNUZQcU9Ye"
Content-Disposition: inline


--tsOsTdHNUZQcU9Ye
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jun 19, 2016 at 11:45:47PM +0900, Takashi Sakamoto wrote:
> (remove C.C. to lkml. This is not so major feature.)
>=20
> On Jun 19 2916 07:45, Henrik Austad wrote:
> >snip
> >
> >802.1Q gives you low latency through the network, but more importantly, =
no
> >dropped frames. gPTP gives you a central reference to time.
>=20
> When such a long message is required, it means that we don't have
> enough premises for this discussion.

Isn't a discussion part of how information is conveyed and finding parts=20
that require more knowledge?

> You have just interests in gPTP and transferring AVTPDUs, while no
> interests in the others such as "what the basic ideas of TSN come
> from" and "the reason that IEEE 1722 refers to IEC 61883 series
> which is originally designed for IEEE 1394 bus" and "the reason that
> I was motivated to join in this discussion even though not a netdev
> developer".

I'm sorry, I'm not sure I follow you here. What do you mean I don't have=20
any interest in where TSN comes from? or the reason why 1722 use IEC 61883?=
=20
What about "they picked 61883 because it made sense?"

gPTP itself is *not* about transffering audio-data, it is about agreeing on=
=20
a common time so that when you *do* transfer audio-data, the samplerate=20
actually means something.

Let me ask you this; if you have 2 sound-cards in your computer and you=20
want to attach a mic to one and speakers to the other, how do you solve=20
streaming of audio from the mic to the speaker If you answer does not=20
contain something akin to "different timing-domain issues", I'd be very=20
surprised.

If you are interested in TSN for transferring *anything*, _including_=20
audio, you *have* to take gPTP into consideration. Just as you have to=20
think about stream reservation, compliant hardware and all the different=20
subsystems you are going to run into, either via kernel or via userspace.

> Here, could I ask you a question? Do you know a role of cycle start
> packet of IEEE Std 1394?

No, I do not.

I have only passing knowledge of the firewire standard, I've looked at the=
=20
encoding described in 1722 and added that to the alsa shim as an example of=
=20
how to use TSN. As I stated, this was a *very* early version and I would=20
like to use TSN for audio - and more work is needed.

> If you think it's not related to this discussion, please tell it to
> me. Then I'll drop out from this thread.

There are tons of details left and right, and as I said, I'm not  all to=20
familiar with firewire. I know that one of the authors behind the firewire=
=20
standard happened to be part of 1722 standard.

I am currently working my way through the firewire-stak paper you've=20
written, and I have gotten a lot of pointers to other areas I need to dig=
=20
into so I should be busy for a while.

That being said, Richard's point about a way to find sample-rate of a=20
hardware device and ways to influence that, is important for AVB/TSN.

> History Repeats itself.

?

> Takashi Sakamoto

--=20
Henrik Austad

--tsOsTdHNUZQcU9Ye
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAldnsjAACgkQ6k5VT6v45lmoigCeIIaItq1VgOUztudYjepQYaJf
Fa8Anjte/cQzdBzNC5bW02x2AK+rx96S
=CK9G
-----END PGP SIGNATURE-----

--tsOsTdHNUZQcU9Ye--

--===============6674882102356082472==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============6674882102356082472==--
