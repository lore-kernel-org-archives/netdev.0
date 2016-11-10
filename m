From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [Intel-wired-lan] [PATCH] igb: use igb_adapter->io_addr instead
 of e1000_hw->hw_addr
Date: Thu, 10 Nov 2016 18:28:07 +0100
Message-ID: <20161110172807.GH24351@calimero.vinschen.de>
References: <1478588780-24480-1-git-send-email-caoj.fnst@cn.fujitsu.com>
 <20161108164214.GF31855@calimero.vinschen.de>
 <alpine.NEB.2.20.17.1611080910530.6177@chris.i8u.org>
 <20161108183739.GA3744@calimero.vinschen.de>
 <CAKgT0UeaoGfOOC1=h4pGk+=FDd5EqvgRGAdk1StLuiW1-M8tVA@mail.gmail.com>
 <20161110093549.GA24351@calimero.vinschen.de>
 <alpine.NEB.2.20.17.1611100544220.6177@chris.i8u.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="imjhCm/Pyz7Rq5F2"
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Cao jin <caoj.fnst@cn.fujitsu.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        =?utf-8?B?SXp1bWksIFRha3Uv5rOJIOaLkw==?=
        <izumi.taku@jp.fujitsu.com>
To: Hisashi T Fujinaka <htodd@twofifty.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.NEB.2.20.17.1611100544220.6177@chris.i8u.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--imjhCm/Pyz7Rq5F2
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Nov 10 05:48, Hisashi T Fujinaka wrote:
> On Thu, 10 Nov 2016, Corinna Vinschen wrote:
> > On Nov  8 11:33, Alexander Duyck wrote:
> ...
> > > The question I would have is what is reading the device when it is in
> > > this state.  The watchdog and any other functions that would read the
> > > device should be disabled.
> > >=20
> > > One possibility could be a race between a call to igb_close and the
> > > igb_suspend function.  We have seen some of those pop up recently on
> > > ixgbe and it looks like igb has the same bug.  We should probably be
> > > using the rtnl_lock to guarantee that netif_device_detach and the call
> > > to __igb_close are completed before igb_close could possibly be called
> > > by the network stack.
> >=20
> > Do you have a pointer to the related ixgbe patch, by any chance?
> ...
> Here's the initial patch for igb I have, but it's on hold awaiting more
> changes in ixgbe regarding AER.

Thanks a lot!


Corinna

--imjhCm/Pyz7Rq5F2
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYJK4nAAoJEPU2Bp2uRE+gmVAP/iftrKpyTIWgKNvhBMrmpuhl
I3IzGMbATPo8KQYT0Y04onzsum8sTR3bdgCcoXVHdr5gtClIMoHDV2xEeGPxfarm
bQ1t68h2p2syDik3DdeqGbaDNexMndN670bqG92PnrCISRoWra8w7hNcj9taMbQy
5egR2Tnz4xplM7X935lfi6/96Q36+k4zgTm0kRLNkXXd19fyYpuLHujglW67RDn9
6VRABGysi5/E59NI/J5sD7eBkVUaOltgHGGQlmRVrt/4MaPrMGIdaswHaDi653jK
zWqSsdUpTLVFYyH02xshPykIC1FSAY7JYVnOzAqNAPIpBfxyTGzT1yzltisXX6kK
1TYu+jrQjWVNech8zEHhog+AaMxOe7Izv/YCXr2BcRTLpmZYZbVqAsigPtA2gumX
KbtYxbdc/hCM72Og3Uxff/z7SVexXlDMolYPw8H9GCzVv3PNDvPosBMuWf7lx6ZY
GgA8E1jKm1+18UVkjMd7RrH/0io+jVUi+1FABhfyS/NO3D6V3rGCnSqXS4tmmXn+
4eRG5ZW5NizvyPUbw9zUXrHqH5HAQfvrJsLz1qszzm8FY86h3FzacrA0paNYhIPt
Ev0IEVH/ow70Z6qQCipcCAhTFsOcHrY581EH8p9IfGiMH93Y9wjoLaJSNN71ZCWg
cquZfauU0x1gdWER9CAD
=1iD8
-----END PGP SIGNATURE-----

--imjhCm/Pyz7Rq5F2--
