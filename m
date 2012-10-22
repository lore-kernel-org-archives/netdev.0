From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH 5/6] drivers: net: ethernet: cpts: implement cpts
 hardware clock
Date: Mon, 22 Oct 2012 12:38:22 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293E9FD94D@DBDE01.ent.ti.com>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <1350427518-7230-6-git-send-email-mugunthanvnm@ti.com>
 <20121020134331.GA5444@netboy.at.omicron.at>
 <EB1619762EAF8B4E97A227FB77B7E0293E9FD709@DBDE01.ent.ti.com>
 <20121022114435.GF2285@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:34185 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828Ab2JVMi1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 08:38:27 -0400
In-Reply-To: <20121022114435.GF2285@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Monday, October 22, 2012 5:15 PM
> To: N, Mugunthan V
> Cc: netdev@vger.kernel.org; davem@davemloft.net
> Subject: Re: [PATCH 5/6] drivers: net: ethernet: cpts: implement cpts
> hardware clock
> 
> On Mon, Oct 22, 2012 at 10:55:55AM +0000, N, Mugunthan V wrote:
> >
> > The CPTS found in DM81XX and AM335X is of same version, only the CPSW
> version
> > is different in both SoCs.
> 
> Actually, the CPTS appears to be different between DM81XX and AM335X.
> 
> The DM81XX has a CPTS_RFTCLK_SEL which is not found in the AM335X.
> 

CPTS ref clock is not part of CPTS module, its external to CPTS module.
During IP integration, this ref clock can be connected to any clock
available. In AM335X this ref clock is tied to 250MHz clock, in DM81XX
the same is connected to a MUX where the CPTS ref clock can be programmed.

Regards
Mugunthan V N
