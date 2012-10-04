From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: RE: [PATCH] net: sunrpc: xdr: Change message to pr_debug level
Date: Thu, 4 Oct 2012 14:51:54 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9090049AD@SACEXCMBX04-PRD.hq.netapp.com>
References: <1349360495-29325-1-git-send-email-fabio.estevam@freescale.com>
 <201210041625.23710.marex@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Marek Vasut <marex@denx.de>,
	Fabio Estevam <fabio.estevam@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4455 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965287Ab2JDOv4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 10:51:56 -0400
In-Reply-To: <201210041625.23710.marex@denx.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Marek Vasut [mailto:marex@denx.de]
> Sent: Thursday, October 04, 2012 7:25 AM
> To: Fabio Estevam
> Cc: davem@davemloft.net; Myklebust, Trond; netdev@vger.kernel.org;
> linux-nfs@vger.kernel.org
> Subject: Re: [PATCH] net: sunrpc: xdr: Change message to pr_debug level
> 
> Dear Fabio Estevam,
> 
> > commit 49f6189 (SUNRPC: Optimise away unnecessary data moves in
> > xdr_align_pages) has added a pr_info that floods dmesg when booting
> > via NFS.
> >
> > There is also a note in the commit log: "Warning! Contains debugging
> > printks!"
> >

...which meant that it contained debugging code, and was obviously not appropriate for merging upstream. The final version has already dropped the debugging printks.

Trond
