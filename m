From: Ian Jackson <Ian.Jackson@eu.citrix.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Wed, 15 Apr 2015 11:54:33 +0100
Message-ID: <21806.17257.971957.13215@mariner.uk.xensource.com>
References: <21795.62414.465476.464027@mariner.uk.xensource.com>
	<1428425741.4212.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<21796.6843.983774.271495@mariner.uk.xensource.com>
	<21796.7755.270785.292996@mariner.uk.xensource.com>
	<1428448869.4212.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<1428448976.4720.15.camel@prashant>
	<21797.13348.524963.29127@mariner.uk.xensource.com>
	<1428543798.4720.20.camel@prashant>
	<21798.24161.922394.539733@mariner.uk.xensource.com>
	<1428595851.4720.22.camel@prashant>
	<21798.44949.156680.399387@mariner.uk.xensource.com>
	<21798.46590.928152.666550@mariner.uk.xensource.com>
	<1428602883.4720.31.camel@prashant>
	<21799.59138.666831.970946@mariner.uk.xensource.com>
	<5528D4F0.6060203@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Prashant <prashant@broadcom.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	"David Vrabel" <david.vrabel@citrix.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:4738 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751400AbbDOKyg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 06:54:36 -0400
In-Reply-To: <5528D4F0.6060203@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prashant writes ("Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]"):
> I tried to reproduce the problem on 32 bit 3.14.34 stable kernel 
> baremetal, with iommu=soft swiotlb=force but no luck, no drops or 
> errors. I did not try with Xen 64 bit yet. Btw I need a pcie analyzer 
> trace to confirm the problem. Is it feasible to capture at your end ?

In private correspondence with Prashant we have established that
Prashant was using a different kernel configuration.  Prashant
provided me with their kernel and module binaries, which work in my
environment.

I have also established that I can reproduce the problem with 3.14.37
(`iommu=soft swiotlb=force' baremetal => all rx wholly corrupted).

The kernel config I was using is here:
  http://logs.test-lab.xenproject.org/osstest/logs/50387/build-i386-pvops/build/config

As far as I am aware no-one at Broadcom has attempted a build and test
using my kernel config.

Thanks,
Ian.
