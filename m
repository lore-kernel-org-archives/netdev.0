From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: sky2: Use seq_putc() in sky2_debug_show()
Date: Mon, 8 May 2017 22:50:12 -0700
Message-ID: <20170508225012.508f24c0@xeon-e3>
References: <1f36d45e-3ca9-bfb8-0634-901c42390e2c@users.sourceforge.net>
        <8594c152-68a4-c0c7-b4c6-49c753b0c748@gmx.de>
        <a85959a8-a357-d8e0-d7e9-617e2052aed6@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Lino Sanfilippo <LinoSanfilippo@gmx.de>, netdev@vger.kernel.org,
        Mirko Lindner <mlindner@marvell.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a85959a8-a357-d8e0-d7e9-617e2052aed6@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 8 May 2017 19:42:46 +0200
SF Markus Elfring <elfring@users.sourceforge.net> wrote:

> > Which issue do you mean? I dont see any issue you fix here. =20
>=20
> Are the run time characteristics a bit nicer for the function =E2=80=9Cse=
q_putc=E2=80=9D
> in comparison to the function =E2=80=9Cseq_puts=E2=80=9D for printing a s=
ingle line break here?
>=20
> Regards,
> Markus

I would put this in why bother category. seq_puts is correct and this is on=
ly
in diagnostic output useful to developer and disabled on most distro kernels
