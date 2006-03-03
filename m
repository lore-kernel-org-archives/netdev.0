From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH] powerpc: ibmveth: Harden driver initilisation for kexec
Date: Fri, 3 Mar 2006 12:10:47 +1100
Message-ID: <200603031210.53220.michael@ellerman.id.au>
References: <20060131041055.5623C68A46@ozlabs.org>
	<200603031122.51174.michael@ellerman.id.au>
	<20060302163423.f758c5bc.rdunlap@xenotime.net>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0913780759=="
Cc: netdev@vger.kernel.org, "Randy.Dunlap" <rdunlap@xenotime.net>,
	jgarzik@pobox.com, anton@samba.org
Return-path: <linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: linuxppc64-dev@ozlabs.org
In-Reply-To: <20060302163423.f758c5bc.rdunlap@xenotime.net>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

--===============0913780759==
Content-Type: multipart/signed;
  boundary="nextPart2908517.1L74LIa63z";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart2908517.1L74LIa63z
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Fri, 3 Mar 2006 11:34, Randy.Dunlap wrote:
> On Fri, 3 Mar 2006 11:22:45 +1100 Michael Ellerman wrote:
> > Hi Jeff,
> >
> > I realise it's late, but it'd be really good if you could send this up
> > for 2.6.16, we're hosed without it.
>
> I'm wondering if this means that for every virtual/hypervisor
> situation, we have to modify any $interested_drivers.
> Why wouldn't we come up with a cleaner solution (in the long term)?
>
> E.g., could the hypervisor know when one of it's virtual OSes
> dies or reboots and release its resources then?

It does exactly that for a regular reboot, but when we kexec we _don't_ die=
 or=20
reboot, as far as the Hypervisor is concerned it's all systems go.

It's something of a double-edged sword, we're totally in control which give=
s=20
us lots of flexibility, and _fast_ reboot times, but we also have to do a b=
it=20
of extra stuff (ie. this patch) to keep things sane.

cheers

=2D-=20
Michael Ellerman
IBM OzLabs

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--nextPart2908517.1L74LIa63z
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBEB5eddSjSd0sB4dIRAm1sAJ4kJtzE0yr0NyAchxgdvLRyvz1avwCeP2gh
48/KsIWxm/+knqq2W0z9Kfc=
=3xSW
-----END PGP SIGNATURE-----

--nextPart2908517.1L74LIa63z--

--===============0913780759==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc64-dev mailing list
Linuxppc64-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc64-dev

--===============0913780759==--
