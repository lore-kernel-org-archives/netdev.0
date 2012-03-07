From: deepaksi <deepak.sikri@st.com>
Subject: Re: [PATCH 3/6] stmmac: Add support for CPU freq notifiers.
Date: Wed, 7 Mar 2012 12:47:34 +0530
Message-ID: <4F570B8E.1010104@st.com>
References: <1330692928-30330-1-git-send-email-deepak.sikri@st.com> <1330692928-30330-2-git-send-email-deepak.sikri@st.com> <1330692928-30330-3-git-send-email-deepak.sikri@st.com> <1330692928-30330-4-git-send-email-deepak.sikri@st.com> <4F54D62B.2080502@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: spear-devel <spear-devel@list.st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:39735 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750739Ab2CGHSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 02:18:10 -0500
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id C17D0117
	for <netdev@vger.kernel.org>; Wed,  7 Mar 2012 07:09:39 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas4.st.com [10.80.176.69])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id A1A6C1163
	for <netdev@vger.kernel.org>; Wed,  7 Mar 2012 07:18:04 +0000 (GMT)
In-Reply-To: <4F54D62B.2080502@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello Peppe,

> Hello Deepak
>
> this patch doesn't apply on net.git.

I would rebase it again on net.git and send
>
> Concerning the stmmac_clk_csr_set it should treat all the other divisor
> values as I've just told you in the email #2.

I looked through the other divisor values also,. The input clock range 
coming through those divisors were
very much overlapping the 2.5 MHz range.

As I had requested to consider the 12.5 MHz MDIO clock provision as a 
separate patch, I would seek
some more discussions on this particular thing.

> All the defines from the patch #2:
>
> +/* CSR Frequency Access Defines*/
> +#define CSR_F_20M	20000000
> +#define CSR_F_35M	35000000
> +#define CSR_F_60M	60000000
> +#define CSR_F_100M	100000000
> +#define CSR_F_150M	150000000
> +#define CSR_F_250M	50000000
> +#define CSR_F_300M	300000000
>
>
> should be moved from linux/stmmac.h to stmicro/stmmac/common.h

ok

>
> In the end, I kindly ask you to try to remove some of not necessary
> #ifdef CONFIG_HAVE_CLK  inside the C file.
>
> Indeed stmmac_clk is be null in case of there is not this support.
>
> Also I wonder if stmmac_clk could be renamed as: stmmac_csr_clk.

Its only at one place that we will need the conditional macro, while we 
do clk_get. Rest of the
macros could be do away with.
I would also rename the stmmac_clk to stmmac_csr_clk.

>
> Pls, resend the patch against net-git so i'll be happy to continue the
> review ;-)
Sure


Regards
Deepak
