From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 31/31] timer: Switch to testing for .function instead of
 .data
Date: Fri, 01 Sep 2017 14:34:17 -0700
Message-ID: <1504301657.3922.47.camel@intel.com>
References: <1504222183-61202-1-git-send-email-keescook@chromium.org>
         <1504222183-61202-32-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-r9bmlAtWiFfE64fwCMV8"
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        linux-pm@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-input@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>,
        Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1504222183-61202-32-git-send-email-keescook@chromium.org>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-r9bmlAtWiFfE64fwCMV8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2017-08-31 at 16:29 -0700, Kees Cook wrote:
> In several places, .data is checked for initialization to gate early
> calls to del_timer_sync(). Checking for .function is equally valid,
> so
> switch to this in all callers.
>=20
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Cc: Pavel Machek <pavel@ucw.cz>
> Cc: Len Brown <len.brown@intel.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
> Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: Sean Hefty <sean.hefty@intel.com>
> Cc: Hal Rosenstock <hal.rosenstock@gmail.com>
> Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: linux-pm@vger.kernel.org
> Cc: linux-rdma@vger.kernel.org
> Cc: linux-input@vger.kernel.org
> Cc: intel-wired-lan@lists.osuosl.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

For the changes to i40e...

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
--=-r9bmlAtWiFfE64fwCMV8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAlmp0lkACgkQ5W/vlVpL
7c64JhAAnNOjvCkziBlORy2Of97GbgFpmxmjNsLPzxNoH/8R3Y6vD3PTDHcwPEGM
Yks7MMLwKEWn3yctxB6GyswNAS/+4BUlnlXveQ11DiZ3O5mmHamNkj4Gtn2fvbML
vfjaUDKBtNRPw6M+R8cQ59XasrykDEPmeS3L1WoLOec9z4Xe6MLkznvVMDXUlb6V
pEfCDKcsFsHt2MYgHqSoVWJuprnsnXElrHjGoxVqJZVuEPqWmbXj+4Qka+2vkNw9
yiS4qW48E77QsAmIkORvpYi60D9jYF3WYkPsZ/Eqi1MtzIEmiDBJZanfcdQJH/WL
U8QUXkSiQXxz6wcbIOEXStNhM8avvjNjziisJAK05OpAmkQV9hBwD3sysRBthK5G
5JI6RjJRCp41Xg3PD5JzoJ+/OTBywbro8iqr7njKo6KpuiBL+KtXWIznEamLcu3/
2YTgjZzF+eIUOBhDF8cOT3OFs88c8YPRHjuydPBzkPlmIdOM4QjWPpz9ZFeB2itX
cHig4zcZ733chcWEhXCaUIT+TY5QkAZCRueH6ed+sWzFYdnFiFdsWgNxhRKNjRru
cTnF70LBOSMyccRYdC1ZOmcga8g4algS1cPradjAkQU10Y/+3aUx17pRy4SqJNOR
lLvSAXqqM4iYmaZsGj+W/X23T9lYsseZHtvktGDLZioQibhg7rw=
=Myq9
-----END PGP SIGNATURE-----

--=-r9bmlAtWiFfE64fwCMV8--

