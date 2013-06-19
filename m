From: Tomi Valkeinen <tomi.valkeinen@ti.com>
Subject: Re: [PATCH] build some drivers only when compile-testing
Date: Wed, 19 Jun 2013 10:19:53 +0300
Message-ID: <51C15B99.6000701@ti.com>
References: <1369214326-6558-1-git-send-email-jslaby@suse.cz> <20130523022327.GB6159@kroah.com> <519D8876.9050405@suse.com> <51BF6BFF.7050705@suse.cz> <51C1595D.60706@ti.com> <51C159F8.8090604@suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="----enig2RPXPEATWHHXMCEQQNMOX"
Cc: Jeff Mahoney <jeffm@suse.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<jirislaby@gmail.com>, <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	<linux-usb@vger.kernel.org>,
	Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
	<linux-geode@lists.infradead.org>, <linux-fbdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>,
	<netdev@vger.kernel.org>, Ben Hutchings <ben@decadent.org.uk>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	Michal Marek <mmarek@suse.cz>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51C159F8.8090604@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------enig2RPXPEATWHHXMCEQQNMOX
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 19/06/13 10:12, Jiri Slaby wrote:
> On 06/19/2013 09:10 AM, Tomi Valkeinen wrote:
>> On 17/06/13 23:05, Jiri Slaby wrote:
>>
>>> The last point I inclined to the Greg's argument to remove the
>>> EXPERT dependency.
>>>
>>> So currently I have what is attached... Comments?
>>
>> The patch looks a bit odd with the USB_CHIPIDEA_IMX parts. You're
>> not adding COMPILE_TEST there, but you're adding a totally new
>> config option, and also changing the Makefile.
>=20
> Look:
>=20
> +config USB_CHIPIDEA_IMX
> +       bool "ChipIdea IMX support"
> +       depends on OF_DEVICE && (ARM || COMPILE_TEST)
>=20
> COMPILE_TEST added here ----------------^^^^^^^^^^^^

My point was that you're not adding COMPILE_TEST to an existing config
option, you're creating a totally new config option.

As I said, that's probably ok, but it'd be nice to mention extra things
like that in the desc. The pedantic approach would be to do the makefile
and Kconfig change in an earlier patch, and then add only COMPILE_TEST.

 Tomi



------enig2RPXPEATWHHXMCEQQNMOX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJRwVuZAAoJEPo9qoy8lh71g7EQAI6G5EDRLYvhxOPkuH6W0kYs
qKqNBwqdqWRLuqDy5j8Wq9Mxkrxvjz4yW4922autLLJx3cJOJmIlVFLGXOvMLJCq
wsLPq0U/sF6XYPLLRmHQ2AAk7XqOMgWtyEK5YT2Jjc0ZqdTFoCh04k85pSWxTqHm
5h6B5ZdSFeGXbWhZP0EhyP9MKxXt2G0uw4ihOzuoPu7ey3S3/5+AYqE5SVePKgoV
T1CS8SWXtVZve1m1QkJBAdO3eWdkzzj5lHgNqg4ikyIyhRA2f7DG4ANtU3NtokhY
ByEb3ABDoy838nP761a/+mWh1bTEl055ZkEsFgSTnIGU4Tmy08mIHASGT9dx6hxa
YHHZjf7p1FmyjRm/qPKhKAL4pTWJ+FtuVNbrPzlEJhjaUuWYRPjk1O1mjL+FANHK
Nr4FbjmSIyXAJti2uP3LvL9CFFiB4WJlmlkIpeSnJYek1eEXaycbyHgDc94ppCEo
Icgvq4nOWYNjNe/ZCgNYS2glpeRb2uiTPfHr+dyDaLM3igCfi20hjkA7ijcsKbA4
OJYpZsuDksUL2GEmIXoE3WXCQpaTw5dWvlrbe3JIOjvhCNuGOR3wrkQkyLzMKF7m
N0SsNXeHwDDGL3yhDCfNCh/Gv996y+2/qFPON/uHgQerPbPAeIC02I/5UiZL3kbU
/WWB3qKHoeczZUs8rMkb
=J1Eo
-----END PGP SIGNATURE-----

------enig2RPXPEATWHHXMCEQQNMOX--
