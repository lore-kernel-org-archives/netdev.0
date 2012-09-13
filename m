From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH net-next] r8169: use unlimited DMA burst for TX
Date: Fri, 14 Sep 2012 01:27:33 +0200
Message-ID: <50526BE5.7040207@redhat.com>
References: <1347234926-5263-1-git-send-email-mschmidt@redhat.com> <20120910.155046.568702072740433838.davem@davemloft.net> <20120910215521.GA930@electric-eye.fr.zoreil.com> <CAF7E57619E34A17A56F6D13097342EA@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hayeswang <hayeswang@realtek.com>,
	"'David Miller'" <davem@davemloft.net>, netdev@vger.kernel.org,
	ivecera@redhat.com
To: "'Francois Romieu'" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16950 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755802Ab2IMX1o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2012 19:27:44 -0400
In-Reply-To: <CAF7E57619E34A17A56F6D13097342EA@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/11/2012 10:09 AM, hayeswang wrote:
> [Francois Romieu wrote:]
>> Hayes, should we:
>> - mimic Realtek's 8168, 8169 and 810x drivers ?
>> - always set TX_DMA_BURST at the max value ?
>> - do something different (per chipset) ?
>
> Our hw engineer suggets to set unlimited for both TX_DMA_BURST and RX_DMA_BURST
> for all chipsets.

Francois,
as this is exactly what the patch does, would you give an ACK?

Michal
