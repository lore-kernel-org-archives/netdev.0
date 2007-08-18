From: Daniel Schaffrath <danielschaffrath@mac.com>
Subject: Re: drivers/infiniband/mlx/mad.c misplaced ;
Date: Sat, 18 Aug 2007 17:14:00 +0200
Message-ID: <28AF5775-A29A-4BB8-83DA-2CAEAEDA164E@mac.com>
References: <20070815235825.GB17004@redhat.com> <1187224811.5906.55.camel@localhost> <20070816084635.GA15985@osiris.boeblingen.de.ibm.com> <Pine.LNX.4.64.0708161248050.22579@kivilampi-30.cs.helsinki.fi> <20070816110116.GA8100@pingi.kke.suse.de>
Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: text/plain; charset=ISO-8859-1;
	delsp=yes	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Joe Perches <joe@perches.com>, Dave Jones <davej@redhat.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>, rolandd@cisco.com,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	Paul Mundt <lethal@linux-sh.org>,
	isdn4linux@listserv.isdn4linux.de, mikep@linuxtr.net,
	Netdev <netdev@vger.kernel.org>, swen@vnet.ibm.com,
	linux390@de.ibm.com, linux-s390@vger.kernel.org, jdike@karaya.com,
	user-mode-linux-devel@lists.sourceforge.net,
	user-mode-linux-user@lists.sourceforge.net,
	netfilter-devel@lists.netfilter.org, coreteam@netfilter.org,
	Satyam Sharma <satyam@infradead.org>
To: Karsten Keil <kkeil@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756124AbXHRPVE@vger.kernel.org>
In-Reply-To: <20070816110116.GA8100@pingi.kke.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 2007/08/16  , at 13:01, Karsten Keil wrote:

> On Thu, Aug 16, 2007 at 01:22:04PM +0300, Ilpo J=E4rvinen wrote:
>>
>> ...I guess those guys hunting for broken busyloops in the other =20
>> thread
>> could also benefit from similar searching commands introduced in thi=
s
>> thread... ...Ccing Satyam to caught their attention too.
>>
>>
>> ./drivers/isdn/hisax/hfc_pci.c
>> 125:	if (Read_hfc(cs, HFCPCI_INT_S1)) ;
>> 155:	if (Read_hfc(cs, HFCPCI_INT_S1)) ;
>> 1483:					if (Read_hfc(cs, HFCPCI_INT_S1)) ;
>> --
>> ./drivers/isdn/hisax/hfc_sx.c
>> 377:	if (Read_hfc(cs, HFCSX_INT_S1)) ;
>> 407:	if (Read_hfc(cs, HFCSX_INT_S2)) ;
>> 1246:					if (Read_hfc(cs, HFCSX_INT_S1)) ;
>> --
>
> These are workaround to not get compiler warnings about ignored retur=
n
> values I got some time ago under some architecture.
Maybe '(void) Read_hfc(cs, HFCSX_INT_S1)' is a better option to get =20
rid of the warnings.
