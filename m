From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 0/7] Phy and mdiobus fixes
Date: Fri, 18 Sep 2015 16:20:51 +0100
Message-ID: <20150918152050.GI21084@n2100.arm.linux.org.uk>
References: <20150918094625.GB21084@n2100.arm.linux.org.uk>
 <20150918095600.GC21084@n2100.arm.linux.org.uk>
 <20150918150128.GV2722@xsjsorenbubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	devicetree@vger.kernel.org, Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>,
	Frank Rowand <frowand.list@gmail.com>,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>,
	Michal Simek <michal.simek@xilinx.com>, netdev@vger.kernel.org,
	Iyappan Subramanian <isubramanian@apm.com>,
	Grant Likely <grant.likely@linaro.org>,
	Li Yang <leoli@freescale.com>,
	Keyur Chudgar <kchudgar@apm.com>,
	linux-arm-kernel@lists.infradead.org
To: =?iso-8859-1?Q?S=F6ren?= Brinkmann <soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150918150128.GV2722@xsjsorenbubuntu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 18, 2015 at 08:01:28AM -0700, S=F6ren Brinkmann wrote:
> Hi Russell,
>=20
> On Fri, 2015-09-18 at 10:56AM +0100, Russell King - ARM Linux wrote:
> > Sorry guys, some of you will get the patches twice, as S=F6ren's na=
me
> > in the header caused vger to reject all the patches.
>=20
> That is the first time I hear about an issue like that. I've been
> receiving patches fine thus far and nobody reported any rejections (b=
y
> vger) to me. Is it some bounce on Xilinx/my side or is vger suddenly
> rejecting non-ascii chars or is something in the mail processing chai=
n
> not properly encoding those chars?
> Please, let me know if I can help with the problem.

It's to do with how I generate the patch set and submit it to my MTA.
The result is that the header fields contain an =F6.  Almost all MTAs
accept this despite it being questionable, but zmailer is extra fussy
and rejects this - and rejected the messages to lkml, netdev, etc.

Normally, the MUA would encode "S=F6ren Brinkmann" in a header into a
7-bit ascii representation as "=3D?utf-8?B?U8O2cmVu?=3D Brinkmann".

It's one of the many issues of not using a MUA to send out patches.

It's also worth noting that git-send-email misses out mime headers
(or used to - which is why I have my own scripts for doing this)
which technically makes the bodies it mails out in violation of the
RFCs.

--=20
=46TTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
