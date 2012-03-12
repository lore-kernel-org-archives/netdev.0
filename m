From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH] stmmac: Add device-tree support
Date: Mon, 12 Mar 2012 18:02:26 +0100
Message-ID: <20120312170226.GE13869@game.jcrosoft.org>
References: <1331561157-3820-1-git-send-email-sr@denx.de>
 <4F5E0993.9020000@gmail.com>
 <201203121606.26926.sr@denx.de>
 <4F5E169D.3070508@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Roese <sr@denx.de>, Rob Herring <robherring2@gmail.com>,
	netdev@vger.kernel.org, Viresh Kumar <viresh.kumar@st.com>,
	devicetree-discuss@ozlabs.org, linux-arm-kernel@lists.infradead.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 3.mo2.mail-out.ovh.net ([46.105.58.226]:55046 "EHLO
	mo2.mail-out.ovh.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753564Ab2CLROF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 13:14:05 -0400
Received: from mail621.ha.ovh.net (b6.ovh.net [213.186.33.56])
	by mo2.mail-out.ovh.net (Postfix) with SMTP id 946F6DC69D7
	for <netdev@vger.kernel.org>; Mon, 12 Mar 2012 18:17:17 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <4F5E169D.3070508@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16:30 Mon 12 Mar     , Giuseppe CAVALLARO wrote:
> On 3/12/2012 4:06 PM, Stefan Roese wrote:
> > Hi Rob,
> > 
> > On Monday 12 March 2012 15:34:59 Rob Herring wrote:
> >> On 03/12/2012 09:05 AM, Stefan Roese wrote:
> >>> This patch adds support to configure the STMMAC ethernet driver via
> >>> device-tree instead of platform_data.
> >>>
> >>> Currently, only the properties needed on SPEAr600 are provided. All
> >>> other properties should be added once needed on other platforms.
> >>>
> >>> Signed-off-by: Stefan Roese <sr@denx.de>
> >>> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> >>> Cc: Viresh Kumar <viresh.kumar@st.com>
> >>> ---
> >>>
> >>>  Documentation/devicetree/bindings/net/stmmac.txt   |   38 +++++++++++
> >>>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   66
> >>>  +++++++++++++++++++- 2 files changed, 103 insertions(+), 1 deletion(-)
> >>>  create mode 100644 Documentation/devicetree/bindings/net/stmmac.txt
> >>>
> >>> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt
> >>> b/Documentation/devicetree/bindings/net/stmmac.txt new file mode 100644
> >>> index 0000000..386a47f
> >>> --- /dev/null
> >>> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> >>> @@ -0,0 +1,38 @@
> >>> +* STMicroelectronics 10/100/1000 Ethernet driver (GMAC)
> >>> +
> >>> +Required properties:
> >>> +- compatible: Should be "stm,gmac"
> >>
> >> This is too generic. This should be 1 string per version of h/w.
> > 
> > Viresh, Giuseppe, can you please suggest a proper string for the SPEAr600 
> > STMMAC core, including version?
> >  
> >> 'stm' should be 'st' according to vendor-prefixes.txt.
> 
> I'm not familiar with devicetree; maybe we should have:
> 
> "stmicro,mac100"
> "stmicro,gmac"
> 
> or: st instead of stmicro if you prefer.
you need to put the first soc where the ip appear on gmac it's sti7105

but with PM IIRC it's sti7108

Best Regards,
J.
