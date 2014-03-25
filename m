From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/4 V2] Ethernet drivers in 3.14-rc3 kernel: fix 3
 buffer overflows triggered by hardware devices
Date: Tue, 25 Mar 2014 17:05:00 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6E8C3C@AcuExch.aculab.com>
References: <CAKPWWNFZc8v04-GM5Ttoa-CW_zhNmfMCYO2Q-Yh-75qitSUpiA@mail.gmail.com>
	<20140324.131733.723749970605014851.davem@davemloft.net>
	<CAKPWWNF982P7PtuoySy6ncU1mCNFm2RBMEDKr3-QKoCKU-6AMw@mail.gmail.com>
	<20140324.143512.68893694230434555.davem@davemloft.net>
	<1395697861.2832.84.camel@deadeye.wl.decadent.org.uk>
	<CAKPWWNFhqP==HfQC6aV=OFs6Ud6bBDa9hpCrvih8BxDUDo87JA@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6E8463@AcuExch.aculab.com>
 <CAKPWWNGQ9f+X3HxQx=cWdQVW4M9VQbPJ7gm68OzKn_wu=tmmSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Grant Grundler <grantgrundler@gmail.com>
To: 'Alon Nafta' <alon@privatecore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57178 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753799AbaCYRFp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 13:05:45 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20716-03 for <netdev@vger.kernel.org>;
 Tue, 25 Mar 2014 17:05:37 +0000 (GMT)
In-Reply-To: <CAKPWWNGQ9f+X3HxQx=cWdQVW4M9VQbPJ7gm68OzKn_wu=tmmSA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alon Nafta 
> Hi David,
> 
> Are you referring to (older) systems without IOMMU? Since IOMMU and
> VT-d (for Intel) exactly solve that security problem.

Yes - I don't know the details of the x86 IOMMU.

	David
 
> On Tue, Mar 25, 2014 at 2:37 AM, David Laight <David.Laight@aculab.com> wrote:
> > From: Alon Nafta
> >> I don't think they should be trusted at all, at least not to a point
> >> where it's feasible for them to execute code on your system.
> >> USB drivers, filesystem drivers, peripheral drivers - they're all on
> >> the same boat, obviously having different levels of severity depending
> >> on driver popularity.
> >
> > On a large number of systems any PCI or PCIe hardware has the
> > ability to read and write any system physical addresses.
> > Not only does this mean that 'dodgy' hardware can change the
> > kernel code, but also any attempt to restrict the memory that
> > the driver itself can access is likely to be circumventable.
> >
> > Yes, you can raise the barrier, but there will always be low
> > points on it.
> >
> >         David
> >
> >
> >
