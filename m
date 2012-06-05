From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: Re: [net-next PATCH 1/3] Added kernel support in EEE Ethtool
 commands
Date: Tue, 5 Jun 2012 11:11:26 +0300
Message-ID: <4FCDBF2E.6040705@broadcom.com>
References: <1338878342-24586-1-git-send-email-yuvalmin@broadcom.com>
 <1338878342-24586-2-git-send-email-yuvalmin@broadcom.com>
 <4FCDBCBA.8040306@st.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Giuseppe CAVALLARO" <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1630 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751275Ab2FEINI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2012 04:13:08 -0400
In-Reply-To: <4FCDBCBA.8040306@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/2012 11:00 AM, Giuseppe CAVALLARO wrote:

> Hello Yuval,
> 
> On 6/5/2012 8:39 AM, Yuval Mintz wrote:
>> This patch extends the kernel's ethtool interface by adding support
>> for 2 new EEE commands - get_eee and set_eee.
> 
>> +	__u32	tx_lpi_enabled;
>> +	__u32	tx_lpi_timer;
> 
> Is the tx_lpi_timer field for the MAC driver as we discussed in the
> past? If yes, so I can use it for the stmmac too.
> 
> Peppe
> 



Hi Peppe,

The short answer is yes.

The API does not specify whether the delay should be made in the MAC
or controller levels, but it should guarantee that if the nic is idle
it should wait that many microseconds prior to asserting its Tx lpi.

Thanks,
Yuval
