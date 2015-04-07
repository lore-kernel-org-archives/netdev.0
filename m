From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen
Date: Tue, 7 Apr 2015 16:22:56 -0700
Message-ID: <1428448976.4720.15.camel@prashant>
References: <21795.62414.465476.464027@mariner.uk.xensource.com>
	 <1428425741.4212.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <21796.6843.983774.271495@mariner.uk.xensource.com>
	 <21796.7755.270785.292996@mariner.uk.xensource.com>
	 <1428448869.4212.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>,
	Ian Jackson <Ian.Jackson@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:57466 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904AbbDGXqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 19:46:23 -0400
In-Reply-To: <1428448869.4212.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-04-07 at 16:21 -0700, Michael Chan wrote:
> On Tue, 2015-04-07 at 19:13 +0100, Ian Jackson wrote:
> > root@bedbug:~# ethtool -S xenbr0 | grep -v ': 0$'
> > no stats available
> > root@bedbug:~# 
> 
> Please provide ethtool -S on the tg3 device.

Ian, in your previous mail you indicated there are no drops or errors
reported on eth0 (assuming this is the tg3 port), which is added to the
bridge xenbr0 is this correct ? If so the rx drops on xenbr0 does not
match with eth0.

please also provide "brctl show", "ethtool -i eth0"
