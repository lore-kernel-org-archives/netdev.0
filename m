From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Patch V2 ] net: doc: cleanup
 Documentation/networking/scaling.txt
Date: Thu, 8 Dec 2011 04:01:18 +0000
Message-ID: <1323316878.18450.60.camel@deadeye>
References: <4EDF77A9.4040808@gmail.com>
	 <20111207.134055.2237590951177376531.davem@davemloft.net>
	 <4EE01B0B.2050900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <rdunlap@xenotime.net>,
	<willemb@google.com>, <benjamin.poirier@gmail.com>,
	<therbert@google.com>, <linux-doc@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <4EE01B0B.2050900@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-12-08 at 10:03 +0800, Shan Wei wrote:
> David Miller said, at 2011/12/8 2:40:
>=20
> > I don't know if it's the encoding you use or something else but you
> > must fix this before submitting any more patches.
> =20
>=20
> Indeed, used default encoding of GB2312, now change it to UTF-8
> according to email-clients.txt and resubmit this patch.
>=20
>=20
> [PATCH v3] net: doc: cleanup Documentation/networking/scaling.txt
>=20
> 1) Fix some typos.
> 2) Change mode of the punctuation from full to half, eg.=E2=80=99,=E2=
=80=9C .
>    So that the punctuation can be read at console.
[...]

UTF-8 is the standard character encoding under Linux and those quotes
will be displayed correctly on most Linux terminals today.  If you must
set your terminal to some other encoding you can use e.g.:

    recode UTF-8 < Documentation/networking/scaling.txt | less

(Be sure to use redirection, otherwise recode will modify the file.)

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

