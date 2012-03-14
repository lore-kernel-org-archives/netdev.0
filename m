From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH] stmmac: Add device-tree support
Date: Wed, 14 Mar 2012 14:37:42 +0100
Message-ID: <201203141437.42673.sr@denx.de>
References: <1331561157-3820-1-git-send-email-sr@denx.de> <201203141307.55808.arnd@arndb.de> <4F609A48.6050702@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org,
	"Jean-Christophe PLAGNIOL-VILLARD" <plagnioj@jcrosoft.com>,
	netdev@vger.kernel.org, devicetree-discuss@ozlabs.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.180]:52095 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932278Ab2CNNiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 09:38:07 -0400
In-Reply-To: <4F609A48.6050702@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 14 March 2012 14:16:56 Giuseppe CAVALLARO wrote:
> >> Concerning the latter, we support several different versions of the
> >> synopsys GMAC cores ... from 3.30 to 3.61a.
> >> 
> >> For example, stx7108 and Stx7109 have the same GMAC core (also SPEAr600
> >> IIRC).
> >> SPEAr13xx has 3.50a
> >> New ST SoC Stxh415 has the 3.60a. etc.
> > 
> > In that case, you should definitely list the exact device versions in the
> > compatible string, like:
> > 
> > compatible = "stm,spear600-gmac", "snps,dw-gmac-3.50a", "snps,dw-gmac";
> 
> looks good to me

So whats the Synopsys version for SPEAr600? 

"snps,dw-gmac-3.50a" ???

Perhaps you should add this info for all supported SoC's into the device 
driver? Or even better into the devicetree bindings Documentation?

Thanks,
Stefan
