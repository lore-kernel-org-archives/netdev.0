From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Bug#690845: ethtool: incorrect WoL detection on Broadcom NX
 II rev < 12
Date: Fri, 19 Oct 2012 12:38:50 -0700
Message-ID: <1350675530.8764.131.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <20121018134717.9579.22997.reportbug@palomino.museglobal.com>
 <1350570748.26833.102.camel@deadeye.wl.decadent.org.uk>
 <CAG2Wgfee=qsiUhAk5reYTypcOZL0kM5A58J+LjB1wuQ_k9FrfA@mail.gmail.com>
 <1350610209.22276.6.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: 690845@bugs.debian.org, "Teodor MICU" <mteodor@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: "Ben Hutchings" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1481 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757094Ab2JSTi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 15:38:59 -0400
In-Reply-To: <1350610209.22276.6.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-19 at 02:30 +0100, Ben Hutchings wrote: 
> Teodor MICU reported that:
> > On Broadcom NX II rev < 12 network interfaces it's not possible to activate
> > WoL using 'ethtool' (it can only be done from the MBA Configuration Menu).
> > 
> > However, even if "Pre-boot Wake On LAN" was enabled 'ethtool' doesn't
> > see this change:
> > 	Supports Wake-on: d
> > 	Wake-on: d
> > 
> > I've just tested that WoL works for this system.
> 
> He's been using Linux 2.6.32 and Linux 3.2, but there don't seem to have
> been any later changes to WoL support in bnx2.
> 
Teodor MICU, please provide lspci -vvv and ethtool -i eth? on the
Broadcom bnx2 device.  Thanks.
