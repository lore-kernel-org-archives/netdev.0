From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH] net: ti: netcp: restore get/set_pad_info() functionality
Date: Thu, 18 Feb 2016 12:13:10 -0500
Message-ID: <56C5FBA6.3040204@ti.com>
References: <1455026303-17014-1-git-send-email-grygorii.strashko@ti.com>
 <20160216.152421.2271194730635382792.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <arnd@arndb.de>, <fcooper@ti.com>,
	<nsekhar@ti.com>, <linux-kernel@vger.kernel.org>, <w-kwok2@ti.com>,
	<mugunthanvnm@ti.com>
To: David Miller <davem@davemloft.net>, <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:37615 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946254AbcBRRNR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 12:13:17 -0500
In-Reply-To: <20160216.152421.2271194730635382792.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/16/2016 03:24 PM, David Miller wrote:
> 
> I would like some of the feedback to be taken into consideration and
> integrated into this patch.
> 
> Part of the reason this regression was introduced was probably because
> the purpose of some fields or descriptor semantics was not defined
> properly.
> 
> Therefore it is absolutely appropriate to properly name and document
> these fields as part of the bug fix.
> 
> Thank you.
> 
David,

I will take over this from Grygorii as he is out of office. 

I propose to keep this patch as is and add additional patch to address
the feedback in the same series (v1). Is that fine with you?

There mainly two feedbacks.
1. Rename the pad to something meaningful. I had suggested to use the word
sw_data to match with what is in the hw spec. Also since this field is not
touched by hardware, I will change the type to u32 as suggested by Arnd.

2. Comment about type cast. I will investigate and make update or discuss this
further 

-- 
Murali Karicheri
Linux Kernel, Keystone
