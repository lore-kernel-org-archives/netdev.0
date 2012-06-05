From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next PATCH 1/3] Added kernel support in EEE Ethtool commands
Date: Tue, 05 Jun 2012 10:16:40 +0200
Message-ID: <4FCDC068.1060605@st.com>
References: <1338878342-24586-1-git-send-email-yuvalmin@broadcom.com> <1338878342-24586-2-git-send-email-yuvalmin@broadcom.com> <4FCDBCBA.8040306@st.com> <4FCDBF2E.6040705@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:35566 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753435Ab2FEIQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 04:16:48 -0400
In-Reply-To: <4FCDBF2E.6040705@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/5/2012 10:11 AM, Yuval Mintz wrote:
> On 06/05/2012 11:00 AM, Giuseppe CAVALLARO wrote:
> 
>> Hello Yuval,
>>
>> On 6/5/2012 8:39 AM, Yuval Mintz wrote:
>>> This patch extends the kernel's ethtool interface by adding support
>>> for 2 new EEE commands - get_eee and set_eee.
>>
>>> +	__u32	tx_lpi_enabled;
>>> +	__u32	tx_lpi_timer;
>>
>> Is the tx_lpi_timer field for the MAC driver as we discussed in the
>> past? If yes, so I can use it for the stmmac too.
>>
>> Peppe
>>
> 
> 
> 
> Hi Peppe,
> 
> The short answer is yes.
> 
> The API does not specify whether the delay should be made in the MAC
> or controller levels, but it should guarantee that if the nic is idle
> it should wait that many microseconds prior to asserting its Tx lpi.

Perfect! So I'll give you the patches for phy and stmmac asap.

Peppe

> 
> Thanks,
> Yuval
> 
> 
