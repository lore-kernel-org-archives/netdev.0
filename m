From: deepaksi <deepak.sikri@st.com>
Subject: Re: [PATCH 03/10] stmmac: sanitize the rx coe and add the type-1
 csum
Date: Sat, 24 Mar 2012 14:51:35 +0530
Message-ID: <4F6D921F.10400@st.com>
References: <1332493721-28309-1-git-send-email-peppe.cavallaro@st.com> <1332493721-28309-4-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Srinivas KANDAGATLA <srinivas.kandagatla@st.com>,
	spear-devel <spear-devel@list.st.com>,
	Shiraz HASHIM <shiraz.hashim@st.com>,
	Viresh KUMAR <viresh.kumar@st.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:48077 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751173Ab2CXJWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2012 05:22:42 -0400
In-Reply-To: <1332493721-28309-4-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




On 3/23/2012 2:38 PM, Giuseppe CAVALLARO wrote:
> [snip]
>
>
> -	priv->rx_coe = priv->hw->mac->rx_coe(priv->ioaddr);
> -	if (priv->rx_coe)
> -		pr_info(" RX Checksum Offload Engine supported\n");
> +	if (priv->plat->rx_coe)
> +		pr_info(" RX Checksum Offload Engine supported (type %d)\n",
> +			priv->plat->rx_coe);
>   	if (priv->plat->tx_coe)
>   		pr_info(" TX Checksum insertion supported\n");
>

rx_coe needs to be enabled. Earlier it was being done. Any specific 
reasons to remove this.
Instead this code needs to be moved post mac reset has been done.

Regards
Deepak
