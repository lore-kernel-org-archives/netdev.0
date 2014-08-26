From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: randconfig build error with next-20140825, in
 drivers/net/ethernet/broadcom/bnx2x
Date: Tue, 26 Aug 2014 06:48:45 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63B2D063@avmb3.qlogic.org>
References: <CA+r1Zhg7=9-tijyfm6604A6jieX1GCj+xdo20ZDUpjLOAUUpRw@mail.gmail.com>
 <20140826061311.GB2622@sudip-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	Jim Davis <jim.epost@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140826061311.GB2622@sudip-PC>
Content-Language: en-US
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Building with the attached random configuration file,
> >
> > drivers/built-in.o: In function `__bnx2x_remove':
> > /home/jim/linux/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:13409:
> > undefined reference to `ptp_clock_unregister'
> > drivers/built-in.o: In function `bnx2x_register_phc':
> > /home/jim/linux/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:13202:
> > undefined reference to `ptp_clock_register'
> > drivers/built-in.o: In function `bnx2x_get_ts_info':
> >
> /home/jim/linux/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c:3498:
> > undefined reference to `ptp_clock_index'
> > make: *** [vmlinux] Error 1
> 
> Hi,I tried to build next-20140825 with your configuration file , but I didn't get any
> error.
> BUILD   arch/x86/boot/bzImage
> Setup is 17068 bytes (padded to 17408 bytes).
> System is 4946 kB
> CRC 13f0e24
> Kernel: arch/x86/boot/bzImage is ready  (#2)
> 
> Am I missing something in the build ?
> 
> Thanks
> Sudip

I believe this is already fixed by commit f79918afb714
("bnx2x: fix build error with ptp") that was submitted a couple of hours ago.

Cheers,
Yuval
