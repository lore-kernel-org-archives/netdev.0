From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH net-next 0/7] qed*: Add qedr infrastructure support
Date: Tue, 4 Oct 2016 08:04:20 -0400
Message-ID: <ad89ec53-2355-e466-0ceb-92da51cc2a62@redhat.com>
References: <1475348401-31392-1-git-send-email-Yuval.Mintz@caviumnetworks.com>
 <20161003.232446.1827173235395776859.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="K8AW0gIhlqQXNNs1c3WHBlgMhF9Rjmehh"
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Ram.Amrani@caviumnetworks.com, Michal.Kalderon@caviumnetworks.com,
        Ariel.Elior@caviumnetworks.com
To: David Miller <davem@davemloft.net>, Yuval.Mintz@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37828 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752870AbcJDMEh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 08:04:37 -0400
In-Reply-To: <20161003.232446.1827173235395776859.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--K8AW0gIhlqQXNNs1c3WHBlgMhF9Rjmehh
Content-Type: multipart/mixed; boundary="5xiNfpCbXsSsfhnHolv0uSB8uxAEReMlh";
 protected-headers="v1"
From: Doug Ledford <dledford@redhat.com>
To: David Miller <davem@davemloft.net>, Yuval.Mintz@caviumnetworks.com
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
 Ram.Amrani@caviumnetworks.com, Michal.Kalderon@caviumnetworks.com,
 Ariel.Elior@caviumnetworks.com
Message-ID: <ad89ec53-2355-e466-0ceb-92da51cc2a62@redhat.com>
Subject: Re: [PATCH net-next 0/7] qed*: Add qedr infrastructure support
References: <1475348401-31392-1-git-send-email-Yuval.Mintz@caviumnetworks.com>
 <20161003.232446.1827173235395776859.davem@davemloft.net>
In-Reply-To: <20161003.232446.1827173235395776859.davem@davemloft.net>

--5xiNfpCbXsSsfhnHolv0uSB8uxAEReMlh
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 10/3/2016 11:24 PM, David Miller wrote:
> From: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
> Date: Sat, 1 Oct 2016 21:59:54 +0300
>=20
>> In the last couple of weeks we've been sending RFCs for the qedr
>> driver - the RoCE driver for QLogic FastLinQ 4xxxx line of adapters.
>> Latest RFC can be found at [1].
>>
>> At Doug's advice [2], we've decided to split the series into two:
>>  - first part contains the qed backbone that's necessary for all the
>> configurations relating to the qedr driver, as well as the qede
>> infrastructure that is used for communication between the qedr and qed=
e.
>>  - Second part consists of the actual qedr driver and introduces almos=
t
>> no changes to qed/qede.
>>
>> This is the first of said two parts. The second half would be sent
>> later this week.
>>
>> The only 'oddity' in the devision are the Kconfig options -=20
>> As this series introduces both LL2 and QEDR-based logic in qed/qede,
>> I wanted to add the CONFIG_INFINIBAND_QEDR option here [with default n=
].
>> Otherwise, a lot of the code introduced would be dead-code [won't even=

>> be compiled] until qedr is accepted.
>> As a result I've placed the config option in an odd place - under
>> qlogic's Kconfig. The second series would then remove that option
>> and add it in its correct place under the infiniband Kconfig.
>> [I'm fine with pushing it there to begin with, but I didn't want to
>> 'contaminate' non-qlogic configuration files with half-baked options].=

>>
>> Dave - I don't think you were E-mailed with Doug's suggestion.
>> I think the notion was to have the two halves accepted side-by-side,
>> but actually the first has no dependency issues, so it's also
>> possible to simply take this first to net-next, and push the qedr
>> into rdma once it's merged. But it's basically up to you and Doug;
>> We'd align with whatever suits you best.
>=20
> I'll take this, series applied, thanks.
>=20

Are you going to merge this in 4.9 or is this going into net-next?

--=20
Doug Ledford <dledford@redhat.com>
    GPG Key ID: 0E572FDD


--5xiNfpCbXsSsfhnHolv0uSB8uxAEReMlh--

--K8AW0gIhlqQXNNs1c3WHBlgMhF9Rjmehh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJX85rKAAoJELgmozMOVy/dPIQP/3w1XQAamw/tlCf2gyQUaABn
1rmb6LCFtOcOC/RgDzoj3i1t53Zoy0bPWIWHJj5NkskImGlhAk5bwlRHA/4A67wx
y+srdkUkzZHuhB7bpJFCcnIwdzpyXj3Z3EdOpQznBm8Sv8yU+y0z7JryWv+iI6VC
LSFot4E6PliQ0YC4LaXoVeoyhVMoXzo85+dvOah6ZyhhTBL+z6BW7ly712kAZ1TK
lasVNYVcg142YuUV0nbamD855nTuvooDMIPis9dmmGt+VGmWlMaqj6ntwJH9Ojyh
0YKPD8a5n2V2L04HmRzAL7p0FjHdzJCPxb5dv55KNo8G8pBITMj8yEm8japsyUiB
+QRdDxIaUkeR5vBbdBB8JGjh5/oORwXtxKYJOyCkZpkA2WumX0Dz/pqaquskW78E
LYD7WEhJ3xGBUK1lsttbVGB1jfcnUmiwQKJkKzoBkxnxg9wFH+G9SNX6kWI2mfPs
VwFHlZ7DLVbtRLpT82tzFmL+7aqdMB+2r/gQvqk4v70JXTV7bfLc7qEbW035mjoF
Q7t6LYcGTmmj6w78FdoiefWJeYY9FCBVgU3x4ixOXlS5ojj0ybKNBEY3xydEbtIn
qvwhu01dJem8dpP0b/6WRW5GBwpP2QYpKR2ukXKuNwFRPPuj3ZbiZQ6S7Lrdb3vo
az50Kyjy97ucWyTj0QkS
=LM5k
-----END PGP SIGNATURE-----

--K8AW0gIhlqQXNNs1c3WHBlgMhF9Rjmehh--
