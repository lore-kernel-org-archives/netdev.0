From: deepaksi <deepak.sikri@st.com>
Subject: Re: [PATCH 3/6] stmmac: Add support for CPU freq notifiers.
Date: Wed, 7 Mar 2012 13:58:45 +0530
Message-ID: <4F571C3D.9000804@st.com>
References: <1330692928-30330-1-git-send-email-deepak.sikri@st.com> <1330692928-30330-2-git-send-email-deepak.sikri@st.com> <1330692928-30330-3-git-send-email-deepak.sikri@st.com> <1330692928-30330-4-git-send-email-deepak.sikri@st.com> <4F54D62B.2080502@st.com> <4F55C4FE.7010607@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: spear-devel <spear-devel@list.st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:36135 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754382Ab2CGI3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 03:29:21 -0500
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id E7180114
	for <netdev@vger.kernel.org>; Wed,  7 Mar 2012 08:20:49 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas4.st.com [10.80.176.69])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id F400D1111
	for <netdev@vger.kernel.org>; Wed,  7 Mar 2012 08:29:14 +0000 (GMT)
In-Reply-To: <4F55C4FE.7010607@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Hi Peppe,

On 3/6/2012 1:34 PM, Giuseppe CAVALLARO wrote:
> On 3/5/2012 4:05 PM, Giuseppe CAVALLARO wrote:
> [snip]
>>> +	else
>>> +		priv->plat->clk_csr = STMMAC_CLK_RANGE_150_250M;
>
> Another note is that you are overriding the priv->plat->clk_csr that was
> passed through the platform and used in some case on other architectures.
>
> peppe

I would cross verify and update the code.

Regards
Deepak
