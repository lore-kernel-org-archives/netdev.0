From: Felipe Balbi <felipe.balbi@linux.intel.com>
Subject: Re: [PATCH 00/26] constify local structures
Date: Mon, 12 Sep 2016 16:43:58 +0300
Message-ID: <877fah5j35.fsf@linux.intel.com>
References: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr> <20160911172105.GB5493@intel.com> <alpine.DEB.2.10.1609121051050.3049@hadrien> <20160912131625.GD957@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Cc: linux-renesas-soc@vger.kernel.org, joe@perches.com,
        kernel-janitors@vger.kernel.org,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        linux-pm@vger.kernel.org, platform-driver-x86@vger.kernel.org,
        linux-media@vger.kernel.org, linux-can@vger.kernel.org,
        Tatyana Nikolova <tatyana.e.nikolova@intel.com>,
        Shiraz Saleem <shiraz.saleem@intel.com>,
        Mustafa Ismail <mustafa.ismail@intel.com>,
        Chien Tin Tung <chien.tin.tung@intel.com>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        devel@driverdev.osuosl.org, alsa-devel@alsa-project.org,
        linux-kernel@vger.kernel.org, linux-fbdev@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        tpmdd-devel@lists.sourceforge.net, linux-scsi@vger.kernel.org,
        linux-spi@vger.kernel.org, l
To: Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
        Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160912131625.GD957@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Hi,

Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com> writes:
> On Mon, Sep 12, 2016 at 10:54:07AM +0200, Julia Lawall wrote:
>>=20
>>=20
>> On Sun, 11 Sep 2016, Jarkko Sakkinen wrote:
>>=20
>> > On Sun, Sep 11, 2016 at 03:05:42PM +0200, Julia Lawall wrote:
>> > > Constify local structures.
>> > >
>> > > The semantic patch that makes this change is as follows:
>> > > (http://coccinelle.lip6.fr/)
>> >
>> > Just my two cents but:
>> >
>> > 1. You *can* use a static analysis too to find bugs or other issues.
>> > 2. However, you should manually do the commits and proper commit
>> >    messages to subsystems based on your findings. And I generally think
>> >    that if one contributes code one should also at least smoke test ch=
anges
>> >    somehow.
>> >
>> > I don't know if I'm alone with my opinion. I just think that one should
>> > also do the analysis part and not blindly create and submit patches.
>>=20
>> All of the patches are compile tested.  And the individual patches are
>
> Compile-testing is not testing. If you are not able to test a commit,
> you should explain why.

Dude, Julia has been doing semantic patching for years already and
nobody has raised any concerns so far. There's already an expectation
that Coccinelle *works* and Julia's sematic patches are sound.

Besides, adding 'const' is something that causes virtually no functional
changes to the point that build-testing is really all you need. Any
problems caused by adding 'const' to a definition will be seen by build
errors or warnings.

Really, just stop with the pointless discussion and go read a bit about
Coccinelle and what semantic patches are giving you. The work done by
Julia and her peers are INRIA have measurable benefits.

You're really making a thunderstorm in a glass of water.

=2D-=20
balbi

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJX1rEeAAoJEMy+uJnhGpkGoEAQAJuttoDMSYPwtz/VwCtE7bUk
aXQ+cEoH0/iubhhEjft1l3lvO/wFT9jhKieX1Q8qZQtvbIQAhlPcBsF0n5Nj0U1b
jF3w2wGm4i9Li6Njgy6GFnIRLkvWFdTj/y9VpFi/qhcarubD1XWn1rmeCz6z8s9w
uJ19WNX7htXt2iWA5vqAewHen7xufj7nuIZLfU8E227g5N+ePuVNjRwc6zFoD0ZV
iGAIinF/NU+r62zSUxZEUsO1UBxPHITIEFJgO8yOXebQ1iN05oqE/I9yIfQF5Jgw
YU0XIH1tO7hCrFmhJkU9moQeRoRPdvXAV1yAslK+PqzaafW6Z5apOKS1IVeF0peb
Z1T6Mhf1D8n0zU2KeShU9Ycygz1C+QBMWaLPlSPYVbHBW8RwGiDJP8H9eDBLH++J
BjuieYb0HsZYy+8P2PAZOIi0EyyT51p1WfldSYyyI/MH9uTuk/ifdwBESdlkZdBt
3PVZRhRjxSuVC9n4pj+b+CmO02G1WE7hS+EvGMEicP7oCOYIh93VPldGE2Aaltwe
dedqi7JY2WvfDE1kVKjHsIpyraUrN8/kc6OpGuUXsoeyVmAIbrCXLAJpKS43Aw9r
UU7dmuGvrRr8oBxytzoFA7FB8fTzmlTPPurzhOdrSvYvRQGYvOMgz2F9C/BBkimU
wx96Gkyu+FMi4THwN7uU
=p41K
-----END PGP SIGNATURE-----
--=-=-=--
