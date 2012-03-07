From: deepaksi <deepak.sikri@st.com>
Subject: Re: [PATCH 3/6] stmmac: Add support for CPU freq notifiers.
Date: Wed, 7 Mar 2012 12:48:54 +0530
Message-ID: <4F570BDE.40600@st.com>
References: <1330692928-30330-2-git-send-email-deepak.sikri@st.com> <1330692928-30330-3-git-send-email-deepak.sikri@st.com> <1330692928-30330-4-git-send-email-deepak.sikri@st.com> <20120304.205045.1678554604028231988.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peppe CAVALLARO <peppe.cavallaro@st.com>,
	spear-devel <spear-devel@list.st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:48365 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750747Ab2CGHTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 02:19:33 -0500
In-Reply-To: <20120304.205045.1678554604028231988.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi David

+		priv->plat->clk_csr = STMMAC_CLK_RANGE_150_250M;
+
+}

> Unnecessary empty lines, remove them.

ok

>> +			/*
>> +			 * Decide on the MDC clock dynamically based on the
>> +			 * csr clock input.
> Format comments:
>
> 	/* Like
> 	 * this.
> 	 */
>
> Not:
>
> 	/*
> 	 * Like
> 	 * this.
> 	 */

ok

>> +static inline void stmmac_cpufreq_deregister(struct stmmac_priv *priv)
>> +{
>> +
>> +	cpufreq_unregister_notifier(&priv->freq_transition,
> Unnecessary empty line.
>

Will remove.

Regards
Deepak
