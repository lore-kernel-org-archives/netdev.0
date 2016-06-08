From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [bug discuss] fjes driver call trace warning, "PNP0C02" used in
 fjes	seems like a bug,
Date: Wed, 8 Jun 2016 02:27:14 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A7379DCD7@G01JPEXMBYT01>
References: <57515004.1080301@huawei.com>
 <EE11001F9E5DDD47B7634E2F8A612F2E1F76DB68@lhreml507-mbx>
 <E86EADE93E2D054CBCD4E708C38D364A7379C541@G01JPEXMBYT01>
 <EE11001F9E5DDD47B7634E2F8A612F2E1F7715BA@lhreml507-mbx>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: Linuxarm <linuxarm@huawei.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Gabriele Paoloni <gabriele.paoloni@huawei.com>,
	"liudongdong (C)" <liudongdong3@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm02.jp.fujitsu.com ([202.219.69.169]:38945 "EHLO
	mgwkm02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbcFHC1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 22:27:24 -0400
Received: from g01jpfmpwyt01.exch.g01.fujitsu.local (g01jpfmpwyt01.exch.g01.fujitsu.local [10.128.193.38])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 84794AC033B
	for <netdev@vger.kernel.org>; Wed,  8 Jun 2016 11:27:16 +0900 (JST)
In-Reply-To: <EE11001F9E5DDD47B7634E2F8A612F2E1F7715BA@lhreml507-mbx>
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Gab,

> > > > I think that "PNP0C02" should be used to mark any motherboard
> > reserved
> > > > resource and not a specific network driver.
> > > > It seems like a bug in the "fjes" driver.
> >
> >   Extended Socket network device is a shared memory based high-speed
> >   network interface between Extended Partitions of PRIMEQUEST 2000 E2
> >   series. To check if firmware supports Extended Socket network device,
> >   we take use of  "PCP0C02" device and special strings in DSDT.
> >
> >   "fjes" is not only "platform device driver (mainly act as network
> >    driver" but also "acpi driver" . If "PCP0C02" found and it is for
> >    Extended Socket network device, platform_device will be created.
> 
> From my understanding PNP0C02 is not a valid ACPI device HID but it is
> to be used only to reserve motherboard resources.
> 
> Can you please explain your identifier choice?

   Sorry for late.

   Extended Socket network device is not a physical device. This is a
   kind of virtual device in memory region which firmware provides.  
   This driver retrieves resource information 
   (memory reagion address firmware provides and so on)
   via PNP0C02. This resource is firmware reserved resources so we use
   PNP0C02.

   Sincerely,
   Taku Izumi

> 
> Gab
> 
> >
> >   Sincerely,
> >   Taku Izumi
> >
> > > >
> > > > Thanks
> > > >
> > > > Dongdong
> > > >
> > > >
> > > >
> > > >
> > > > _______________________________________________
> > > > linuxarm mailing list
> > > > linuxarm@huawei.com
> > > > http://rnd-openeuler.huawei.com/mailman/listinfo/linuxarm
