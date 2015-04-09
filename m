From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Thu, 9 Apr 2015 09:10:51 -0700
Message-ID: <1428595851.4720.22.camel@prashant>
References: <21795.62414.465476.464027@mariner.uk.xensource.com>
	 <1428425741.4212.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <21796.6843.983774.271495@mariner.uk.xensource.com>
	 <21796.7755.270785.292996@mariner.uk.xensource.com>
	 <1428448869.4212.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <1428448976.4720.15.camel@prashant>
	 <21797.13348.524963.29127@mariner.uk.xensource.com>
	 <1428543798.4720.20.camel@prashant>
	 <21798.24161.922394.539733@mariner.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>
To: Ian Jackson <Ian.Jackson@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:22355 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755828AbbDIQeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 12:34:25 -0400
In-Reply-To: <21798.24161.922394.539733@mariner.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-09 at 12:11 +0100, Ian Jackson wrote:
> Prashant Sreedharan writes ("Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]"):
> > On Wed, 2015-04-08 at 14:59 +0100, Ian Jackson wrote:
> > > Ian Jackson writes ("Re: tg3 NIC driver bug in 3.14.x under Xen"):
> > > > The value for "dropped" increases steadily.  This particular box is on
> > > > a network with a lot of other stuff, so it will be constantly
> > > > receiving broadcasts of various kinds even when I am not trying to
> > > > address it directly.
> > > 
> > Based on the stats, the issue seems to be with the bridge than tg3. Do
> > you have any filters enabled on xenbr0 ?
> 
> No.  I can try to repro the problem without the bridge, if it would
> help.
yes please do
