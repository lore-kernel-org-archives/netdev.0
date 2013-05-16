From: Tomi Valkeinen <tomi.valkeinen@ti.com>
Subject: Re: [PATCH 00/33] devm improvement series, part 1, take 2
Date: Thu, 16 May 2013 16:17:54 +0300
Message-ID: <5194DC82.8050408@ti.com>
References: <1368702961-4325-1-git-send-email-wsa@the-dreams.de>
 <1368705452.15764.217.camel@sauron.fi.intel.com>
 <CAKohpokUy7QfvKkzGH025Zs5VkUhr8zRLeo3caG3LAnLfptzww@mail.gmail.com>
 <1368709862.15764.224.camel@sauron.fi.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0054887462=="
Cc: linux-mips@linux-mips.org, alsa-devel@alsa-project.org,
 Alessandro Zummo <a.zummo@towertech.it>, Wolfram Sang <wsa@the-dreams.de>,
 Alexander Shishkin <alexander.shishkin@linux.intel.com>,
 Viresh Kumar <viresh.kumar@linaro.org>,
 Linus Walleij <linus.walleij@linaro.org>,
 Thierry Reding <thierry.reding@avionic-design.de>, linux-fbdev@vger.kernel.org,
 dri-devel@lists.freedesktop.org, Jaroslav Kysela <perex@perex.cz>,
 linux-ide@vger.kernel.org, linux-mtd@lists.infradead.org,
 linux-i2c@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>,
 ac100@lists.launchpad.net, devel@driverdev.osuosl.org,
 Kukjin Kim <kgene.kim@samsung.com>, Russell King <linux@arm.linux.org.uk>,
 Arnd Bergmann <arnd@arndb.de>, Samuel Ortiz <sameo@linux.intel.com>,
 Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
 Vinod Koul <vinod.koul@intel.com>, linux-pm@vger.kernel.org,
 cpufreq@vger.kernel.org, Eduar
To: <dedekind1@gmail.com>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1368709862.15764.224.camel@sauron.fi.intel.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel/>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: "devel" <devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

--===============0054887462==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="----enig2EHULBAGEHLETABJNANUE"

------enig2EHULBAGEHLETABJNANUE
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 16/05/13 16:11, Artem Bityutskiy wrote:
> On Thu, 2013-05-16 at 18:25 +0530, Viresh Kumar wrote:
>> On 16 May 2013 17:27, Artem Bityutskiy <dedekind1@gmail.com> wrote:
>>> On Thu, 2013-05-16 at 13:15 +0200, Wolfram Sang wrote:
>>>> Despite various architectures and platform dependencies, I managed t=
o
>>>> compile
>>>> test 45 out of 57 modified files locally using heuristics and
>>>> defconfigs.
>>>> If somebody knows how to create a minimal .config with a certain
>>>> kconfig symbol
>>>> (and its dependencies) set, I'd love to hear about it.
>>>
>>> If you find this out, please, share!
>>
>> Are you guys looking for "make savedefconfig" ??
>=20
> No. It is more like:
>=20
> I have changed this strange driver.
>=20
> I want to compile-test my changes.
>=20
> I need a defconfig which would have this driver enabled. I also want to=

> know <arch> for my "make ARCH=3D<arch>" command.

Not quite the same thing, but I sent this a while ago:

http://lkml.indiana.edu/hypermail/linux/kernel/1304.3/02847.html

My "softdepends" feature is probably not needed, as pointed out in the
thread, as the behavior can be implemented with the current Kconfig
language just fine.

I had a quick look at fbdev drivers, and some of them compile fine on
all (well, arm and x86) archs. But many do have real arch dependencies.

I think it'd be a good long term goal to make drivers arch-independent,
and add CONFIG_SHOW_ALL_DRIVERS or such, which would allow compiling
drivers that are not used on your arch, but still compile fine.

 Tomi



------enig2EHULBAGEHLETABJNANUE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJRlNyCAAoJEPo9qoy8lh71l58P/j0OTooy3PHnvOCCS7eRw6IP
95MLCoZruiAk75I2dLxS1wQ2HAHGeLVJlk5gTYtbgMyhzqfZJSpMpEOHNwumYwi3
s7cC2GQsH4d8Epuh9R2C1Jje+8+dMutMzQhkm/L4RZfsmUaBH6GhVBQqtI66eSYR
bV4YTnGUG1ppR+l+ZqFmTT5TmFVprcKfqNg96P1BmutTSCGyEM3oHTSTOLEbdutq
Ms1Ex0zXypQ2p14pCe91eDqnEDjVAclOUTzaVop4ADJ28mh4MnodSeNhb7Yz2nRT
zGMUMu4D1WdUvLEzIawATE4pNh0xyvz0Sn2HVfkWfpWUlkA/3fINpBTIzEVEDL7G
3q4pChhqHX3CTqUyCzVKF/zQ3VUJ9VGAgoTpfZJ8JAeqsPvy1LVgB6j8CtEc0pW2
07K450ptCkRHuE+ziRRBzCK/XJQJySBGpIjWDNsTka2G/QydHZx21rGmURh7Cz7x
+5tDMZzylVPrVipjdlX2aAm4iUXlPlppX1rwRNVpsQ6Uf/dGGQcyOK1bCLuUWiAY
nz0Mzu95h71lYJ/lsr986v1om/GhMh8c9xLx77xQQgklWE6cqpzw7ifnhlqELEDz
CijOLMhn9k3eEtiZqj6J8tz0yXI0HSUjm2GMft479ezmG6kJnyANTY/Jl9hH052s
8XWRsSCRfCgeFVNVLYoN
=mQ7r
-----END PGP SIGNATURE-----

------enig2EHULBAGEHLETABJNANUE--

--===============0054887462==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/devel

--===============0054887462==--
