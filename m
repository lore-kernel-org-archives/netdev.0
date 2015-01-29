From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH] net, ethernet, LLVMLinux: Add missing MODULE_DEVICE_TABLE()
Date: Thu, 29 Jan 2015 11:29:32 +0000
Message-ID: <yw1xlhklbzab.fsf@unicorn.mansr.com>
References: <1422495374-22835-1-git-send-email-behanw@converseincode.com>
	<20150128.224228.1533046356464752424.davem@davemloft.net>
	<3392784.h8cmHX9fyr@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, behanw@converseincode.com,
	sathya.perla@emulex.com, ajit.khaparde@emulex.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	subbu.seetharaman@emulex.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3392784.h8cmHX9fyr@wuerfel> (Arnd Bergmann's message of "Thu, 29
	Jan 2015 10:10:48 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> writes:

> On Wednesday 28 January 2015 22:42:28 David Miller wrote:
>> From: Behan Webster <behanw@converseincode.com>
>> Date: Wed, 28 Jan 2015 17:36:14 -0800
>>=20
>> > Missing MODULE_DEVICE_TABLE for pci ids from benet driver found by=
 clang.
>> >=20
>> > Signed-off-by: Behan Webster <behanw@converseincode.com>
>> > Suggested-by: Arnd Bergmann <arnd@arndb.de>
>>=20
>> Why are you removing the device table?
>
> Behan took a patch that I did earlier and split it up to add descript=
ions.
> The patch is correct, but he either misunderstood or misexpressed the
> intention.
>
> This driver has two identical lines that both say=20
>
> MODULE_DEVICE_TABLE(pci, be_dev_ids);
>
> I don't remember the exact symptom, but llvm/clang trips over this, w=
hile gcc
> silently ignores the second one.

GCC is probably being "helpful" and allowing multiple identical
definitions even though the C spec does not.  Obviously all but one
should go away.  No need to mention llvm, IMO.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
