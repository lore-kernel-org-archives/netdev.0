From: Wei Gu <wei.gu@ericsson.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Fri, 8 Apr 2011 17:41:25 +0800
Message-ID: <D12839161ADD3A4B8DA63D1A134D084026E48BA5DA@ESGSCCMS0001.eapac.ericsson.se>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <1302152327.2701.50.camel@edumazet-laptop>
	 <1302153412.2701.64.camel@edumazet-laptop>
	 <1302157012.2701.73.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9E82@ESGSCCMS0001.eapac.ericsson.se>
	 <1302163650.3357.8.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9F23@ESGSCCMS0001.eapac.ericsson.se>
	 <1302167168.3357.12.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA027@ESGSCCMS0001.eapac.ericsson.se>
	 <1302176811.3357.15.camel@edumazet-laptop>  <4D9DDF43.9080302@intel.com>
	 <1302192218.3357.47.camel@edumazet-laptop> <4D9DE465.1080008@intel.com>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA58D@ESGSCCMS0001.eapac.ericsson.se>
 <1302253651.4409.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:65448 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771Ab1DHJl3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 05:41:29 -0400
In-Reply-To: <1302253651.4409.2.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I just tried the CONFIG_DMAR off and CONFIG_DMAR_DEFAULT_ON not set.
I get a pretty good performance(1.5Mpps 400byte Rx&Tx) with shipped ixg=
be driver.

The I think it is the root cause why I get that low performance previou=
slly.

Is it better to put some notes on the Intel-IOMMU.txt Or somewhere like=
 the Q&A about the " CONFIG_DMAR" in no virtualization setup:)

I will keep testing the large setup by enable the rest 3 NICs, to see h=
ow much we can have with this 4 sock machine.

BTW, even we gain some preformance with this shipped ixgbe driver, but =
it doesn't seem that much scallable compare to the Intel offical releas=
e 3.2.10 driver. I don't know if it is a problem?

Thanks
WeiGu

-----Original Message-----
=46rom: Eric Dumazet [mailto:eric.dumazet@gmail.com]
Sent: Friday, April 08, 2011 5:08 PM
To: Wei Gu
Cc: Alexander Duyck; netdev; Kirsher, Jeffrey T
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel

Le vendredi 08 avril 2011 =E0 16:59 +0800, Wei Gu a =E9crit :
> Hi,
> On my configuration of Linux 2.6.38 we do enabled the CONFIG_DMAR
> CONFIG_DMAR=3Dy CONFIG_DMAR_DEFAULT_ON=3Dy CONFIG_DMAR_FLOPPY_WA=3Dy
> CONFIG_INTR_REMAP=3Dy
>
> But I enabled this DMAR also by default of the RHEL6 2.6.32 kernel,
> which we don't see this problem on this kernel. The only different I
> can see on the config is "CONFIG_DMAR_DEFAULT_ON"
> CONFIG_DMAR=3Dy
> # CONFIG_DMAR_DEFAULT_ON is not set
> CONFIG_DMAR_FLOPPY_WA=3Dy
> CONFIG_INTR_REMAP=3Dy
>
> I could try the same configuration as 2.6.32 for the 2.6.38 kernel by
> unset the CONFIG_DMAR_DEFAULT_ON. And run the test again, hopefully w=
e
> can get the test result next Monday:)

Just say no to CONFIG_DMAR, end of problems, no need to try various kno=
bs and find the solution next month ;)

Unless you have a reason to use it.



