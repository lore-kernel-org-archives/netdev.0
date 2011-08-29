From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 3/9] stmmac: add MMC supports exported via debugfs.
Date: Mon, 29 Aug 2011 14:00:56 +0200
Message-ID: <4E5B7F78.4030803@st.com>
References: <1314259229-13767-1-git-send-email-peppe.cavallaro@st.com> <1314259229-13767-4-git-send-email-peppe.cavallaro@st.com> <20110826.121222.1125604441814245954.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:51468 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751310Ab1H2MBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2011 08:01:11 -0400
In-Reply-To: <20110826.121222.1125604441814245954.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/26/2011 6:12 PM, David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Thu, 25 Aug 2011 10:00:23 +0200
> 
>> This patch adds the MMC management counters support.
>> MMC module is an extension of the register address
>> space and all the hardware counters can be accessed
>> via debugfs.
>> Below an example of the output:
> 
> This is not the appropriate way to expose internal chip counters.
> 
> Please use ethtool statistics for this.

Yes I'll do that and resend all the patches again.

Thanks for the review.
Peppe

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
