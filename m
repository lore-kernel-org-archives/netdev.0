From: "Kalderon, Michal" <Michal.Kalderon@cavium.com>
Subject: RE: [PATCH 1/1] net: ethernet: broadcom: fix improper return value
Date: Sun, 4 Dec 2016 07:59:10 +0000
Message-ID: <SN1PR0701MB1933E2914735C68829CFB13B88800@SN1PR0701MB1933.namprd07.prod.outlook.com>
References: <1480832969-5888-1-git-send-email-bianpan201604@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Pan Bian <bianpan2016@163.com>
To: Pan Bian <bianpan201604@163.com>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "Elior, Ariel" <Ariel.Elior@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480832969-5888-1-git-send-email-bianpan201604@163.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Pan Bian <bianpan2016@163.com>
>=20
> Marco BNX2X_ALLOC_AND_SET(arr, lbl, func) calls kmalloc() to allocate
> memory, and jumps to label "lbl" if the allocation fails. Label "lbl"
> first cleans memory and then returns variable rc. Before calling the macr=
o, the
> value of variable rc is 0. Because 0 means no error, the callers of
> bnx2x_init_firmware() may be misled. This patch fixes the bug, assigning =
"-
> ENOMEM" to rc before calling macro NX2X_ALLOC_AND_SET().
>=20
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=3D189141
>=20
> Signed-off-by: Pan Bian <bianpan2016@163.com>

The title is wrong from net-next; It should have been "bnx2x: Fix improper =
return value".

Acked-by: Michal Kalderon <michal.kalderon@cavium.com>
