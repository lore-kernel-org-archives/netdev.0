From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH for-next 0/2] {IB,net}/hns: Add support of ACPI to the
 Hisilicon RoCE Driver
Date: Thu, 25 Aug 2016 11:00:16 -0400
Message-ID: <6a3c65b0-500e-c097-7ff4-15ec5f1de19c@redhat.com>
References: <1471985090-202472-1-git-send-email-salil.mehta@huawei.com>
 <20160824.215341.1803699371957253329.davem@davemloft.net>
 <F4CC6FACFEB3C54C9141D49AD221F7F91A6E7FA9@lhreml503-mbx>
 <8fa4e921-9dfc-bf2b-32c9-230136536f65@redhat.com>
 <F4CC6FACFEB3C54C9141D49AD221F7F91A6E85C2@lhreml503-mbx>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="bNP4AtXrmsP5VQjlp171EnbkUtbHk23bJ"
Cc: "Huwei (Xavier)" <xavier.huwei@huawei.com>,
        oulijun <oulijun@huawei.com>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Salil Mehta <salil.mehta@huawei.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F91A6E85C2@lhreml503-mbx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--bNP4AtXrmsP5VQjlp171EnbkUtbHk23bJ
Content-Type: multipart/mixed; boundary="tJwjLuts2A5Noqs7v1KerCf0oNxxD7ir3"
From: Doug Ledford <dledford@redhat.com>
To: Salil Mehta <salil.mehta@huawei.com>, David Miller <davem@davemloft.net>
Cc: "Huwei (Xavier)" <xavier.huwei@huawei.com>, oulijun <oulijun@huawei.com>,
 "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
 "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
 "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Linuxarm <linuxarm@huawei.com>
Message-ID: <6a3c65b0-500e-c097-7ff4-15ec5f1de19c@redhat.com>
Subject: Re: [PATCH for-next 0/2] {IB,net}/hns: Add support of ACPI to the
 Hisilicon RoCE Driver
References: <1471985090-202472-1-git-send-email-salil.mehta@huawei.com>
 <20160824.215341.1803699371957253329.davem@davemloft.net>
 <F4CC6FACFEB3C54C9141D49AD221F7F91A6E7FA9@lhreml503-mbx>
 <8fa4e921-9dfc-bf2b-32c9-230136536f65@redhat.com>
 <F4CC6FACFEB3C54C9141D49AD221F7F91A6E85C2@lhreml503-mbx>
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F91A6E85C2@lhreml503-mbx>

--tJwjLuts2A5Noqs7v1KerCf0oNxxD7ir3
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 8/25/2016 10:50 AM, Salil Mehta wrote:

>> I can take both.  I already pulled net-next to get the initial hns roc=
e
>> reset patch from Dave, so these will apply cleanly with my tree and
>> merge cleanly with Dave's due to the common ancestral base.  The only
>> problem is that if you intend to send any other patches that effect
>> this
>> code, then they would need to come through me until the 4.9 merge
>> window
>> is complete so that we don't have later merge conflicts.
> Ok sure, I got your point. Yes, there are few patches we need to push i=
n
> but are related to RoCE CM(Connection Manager) mode and would follow
> soon. There are no further patches we foresee which are for RoCE Driver=
 but are
> dependent upon HNS Ethernet driver.=20

Ok.

> But kindly note, there could be some patches in development in HNS Ethe=
rnet driver
> which might sneak in through net-next. These might not be related to Ro=
CE Driver but
> might have some common files which might lead to conflict again further=
 down
> the line when you try to merge ACPI RoCE reset again. This HNS driver c=
hange
> is very difficult for us to control since amount of development going o=
n in HNS
> is of much higher magnitude than the RoCE as of now. It will be almost =
impossible
> for us to convince internally and shift that entire development being d=
one right
> now on net-next and rebase it to your internal hns-roce branch for a mo=
nth of time
> till 4.9. This will affect many features deadlines internally.=20

This is what Linus wants to avoid.  It's not necessary to shift your
work from one tree to another, what is needed if for your RoCE team and
your net team to plan out what you are going to submit for the next
kernel and provide a complete list of conflicting code patches to both
Dave and myself and allow us to pull those patches into both our trees
so there are no conflicts.  See the recent threads on linux-rdma about
the pull requests from Mellanox.  This is how it needs to be done.
Neither team needs to slow down, or not do your work, you simply need to
plan that work out and provide a common base for Dave and I to apply the
separate patches on top of.

> So, if I understood you correctly, this delta (which could be large), w=
hen next merge
> window open would be taken care by you. And we can expect below to be p=
art of 4.9
> 1) RoCE Base driver (*Already Accepted*)
> 2) ACPI changes for RoCE Driver (*if accepted*)
>    * ACPI changes for the RoCE Driver
>    * ACPI changes for RoCE reset function part of the HNS driver

Both of these changes are already applied to my tree.  However, if you
submit other changes to net-next and it starts generating merge
conflicts, you and the net team are going to get yelled at.  If you are
going to have a shared driver, then you *HAVE* to work as a larger team
and plan your changes you submit to the linux kernel.


--=20
Doug Ledford <dledford@redhat.com>
    GPG Key ID: 0E572FDD


--tJwjLuts2A5Noqs7v1KerCf0oNxxD7ir3--

--bNP4AtXrmsP5VQjlp171EnbkUtbHk23bJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXvwgAAAoJELgmozMOVy/dQQQP/Rk+pwRAGHKCWdFKWtUeay4w
3iIjrTlRHAUO1194dkpjBsAQ2op2d0MqKsjGGxzvgN9oY/9msUV8zc0ECH9TDHU+
3f50hwblaln++9HOrfwQBRx33DGKTqCTAa8J129Qv2bYcOGpSzLs4XYM9CWXHGiY
DgwVG17yucpSnfNzS5c5MweW5Q+g8hBmZc9OF6McBoT68zboSEPRXqwQlKNtUTli
IS6vzKJxJ5c1H+euvvdnV5nbwn47+8JiZwCczGxTUv7e+mXc2bDTeapExKSZz2Mu
4DgOTsLrm2fUm7sk+ytjjcPUbkobpRVmOQfoibPS5b3APaD+O1crtKKmjDe5Fq3U
L6Q2L5Zy7884vQGahl0CYHj3m3Sgr2YB/tvoBFcJci88qvclz6BnSij7HIRumFrg
XZwgleFQA4oziknyQB4OHgSYlDanQCmA/+afNXuI8zCj/iqFO9IxHrdXoc6IGR5a
U03bg0wxFJsLcYuXzVQ9hsGsNX0KhpCU4R3nlGMvvH9s1sqDtq9auiWEcmhtP1rd
Jkpv2a4cpEDrxSsdyZJGdcrqtvMFFm5ggm92HJVegas3vkliWoqYbHrmjOaKetJg
aOyhx2ybAqbvTtVosVU/IRWrjyBNNKybAeWlnvB22IE3sTgTyMAxL5FTDbuJppwW
jpyiWAjFha7uHMScRLPf
=5TDn
-----END PGP SIGNATURE-----

--bNP4AtXrmsP5VQjlp171EnbkUtbHk23bJ--
