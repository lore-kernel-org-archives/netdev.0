From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 2/4] stmmac: consolidate and tidy-up the COE support
Date: Fri, 17 Sep 2010 16:13:25 -0700 (PDT)
Message-ID: <20100917.161325.179286731.davem@davemloft.net>
References: <1284729822-29176-1-git-send-email-peppe.cavallaro@st.com>
	<1284729822-29176-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, js@sig21.net, deepak.sikri@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54655
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753651Ab0IQXNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 19:13:06 -0400
In-Reply-To: <1284729822-29176-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Fri, 17 Sep 2010 15:23:40 +0200

> The first version of the driver had hard-coded the logic
> for handling the checksum offloading.
> This was designed according to the chips included in
> the STM platforms where:
> o MAC10/100 supports no COE at all.
> o GMAC fully supports RX/TX COE.
> 
> This is not good for other chip configurations where,
> for example, the mac10/100 supports the tx csum in HW
> or when the GMAC has no IPC.
> 
> Thanks to Johannes Stezenbach; he provided me a first
> draft of this patch that only reviewed the IPC for the
> GMAC devices.
> 
> This patch also helps on SPEAr platforms where the
> MAC10/100 can perform the TX csum in HW.
> Thanks to Deepak SIKRI for his support on this.
> 
> In the end, GMAC devices for STM platforms have
> a bugged Jumbo frame support that needs to have
> the Tx COE disabled for oversized frames (due to
> limited buffer sizes). This information is also
> passed through the driver's platform structure.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Signed-off-by: Johannes Stezenbach <js@sig21.net>
> Signed-off-by: Deepak SIKRI <deepak.sikri@st.com>

Applied.
