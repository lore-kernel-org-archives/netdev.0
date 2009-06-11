From: Nathan Lynch <ntl@pobox.com>
Subject: Re: [PATCH] Re:[BUILD FAILURE 04/04] Next June 04:PPC64 randconfig
 [drivers/net/ucc_geth.o]
Date: Wed, 10 Jun 2009 21:28:30 -0500
Message-ID: <m3d49btsfl.fsf@pobox.com>
References: <20090610174323.28045.70169.sendpatchset@subratamodak.linux.ibm.com>
 <20090611110523.1fd56a41.sfr@canb.auug.org.au>
 <1244685364.6494.14.camel@subratamodak.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, netdev@vger.kernel.org,
	Li Yang <leoli@freescale.com>,
	Sachin P Sant <sachinp@linux.vnet.ibm.com>,
	Linuxppc-dev <Linuxppc-dev@ozlabs.org>,
	Linux-Next <linux-next@vger.kernel.org>,
	Linux-Kernel <linux-kernel@vger.kernel.org>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: subrata@linux.vnet.ibm.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1244685364.6494.14.camel@subratamodak.linux.ibm.com> (Subrata
 Modak's message of "Thu\, 11 Jun 2009 07\:26\:04 +0530")
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subrata Modak <subrata@linux.vnet.ibm.com> writes:

> On Thu, 2009-06-11 at 11:05 +1000, Stephen Rothwell wrote:
>> Hi Subrata,
>>=20
>> On Wed, 10 Jun 2009 23:13:23 +0530 Subrata Modak <subrata@linux.vnet=
=2Eibm.com> wrote:
>> >
>> >  	/* Find the TBI PHY.  If it's not there, we don't support SGMII =
*/
>> > -	ph =3D of_get_property(np, "tbi-handle", NULL);
>> > +	ph =3D (phandle *)of_get_property(np, "tbi-handle", NULL);
>>=20
>> You don't need this cast because of_get_property() returns "void *".
>
> Stephen,
>
> True. But without this gcc complains:
>
> CC [M]  drivers/net/ucc_geth.o
> drivers/net/ucc_geth.c: In function =E2=80=98ucc_geth_probe=E2=80=99:
> drivers/net/ucc_geth.c:3824: warning: assignment discards qualifiers
> from pointer target type

ph should be declared const phandle *.  Look at other uses of
of_get_property.
