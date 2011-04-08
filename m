From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Fri, 08 Apr 2011 11:07:30 +0200
Message-ID: <1302253651.4409.2.camel@edumazet-laptop>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Wei Gu <wei.gu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36053 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757Ab1DHJHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 05:07:38 -0400
Received: by wya21 with SMTP id 21so2903979wya.19
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2011 02:07:37 -0700 (PDT)
In-Reply-To: <D12839161ADD3A4B8DA63D1A134D084026E48BA58D@ESGSCCMS0001.eapac.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 08 avril 2011 =C3=A0 16:59 +0800, Wei Gu a =C3=A9crit :
> Hi,
> On my configuration of Linux 2.6.38 we do enabled the CONFIG_DMAR
> CONFIG_DMAR=3Dy
> CONFIG_DMAR_DEFAULT_ON=3Dy
> CONFIG_DMAR_FLOPPY_WA=3Dy
> CONFIG_INTR_REMAP=3Dy
>=20
> But I enabled this DMAR also by default of the RHEL6 2.6.32 kernel,
> which we don't see this problem on this kernel. The only different I
> can see on the config is "CONFIG_DMAR_DEFAULT_ON"
> CONFIG_DMAR=3Dy
> # CONFIG_DMAR_DEFAULT_ON is not set
> CONFIG_DMAR_FLOPPY_WA=3Dy
> CONFIG_INTR_REMAP=3Dy
>=20
> I could try the same configuration as 2.6.32 for the 2.6.38 kernel by
> unset the CONFIG_DMAR_DEFAULT_ON. And run the test again, hopefully w=
e
> can get the test result next Monday:)

Just say no to CONFIG_DMAR, end of problems, no need to try various
knobs and find the solution next month ;)

Unless you have a reason to use it.



