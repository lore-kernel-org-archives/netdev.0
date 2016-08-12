From: Timur Tabi <timur@codeaurora.org>
Subject: Re: Aw: [PATCH] [v8] net: emac: emac gigabit ethernet controller
 driver
Date: Fri, 12 Aug 2016 15:39:23 -0500
Message-ID: <57AE33FB.5080905@codeaurora.org>
References: <1470951245-13665-1-git-send-email-timur@codeaurora.org>
 <trinity-1978b11f-5ee9-4e10-b88d-ab126cd976e0-1471033378842@3capp-gmx-bs27>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, davem@davemloft.net,
	f.fainelli@gmail.com
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:51428 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293AbcHLUj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 16:39:27 -0400
In-Reply-To: <trinity-1978b11f-5ee9-4e10-b88d-ab126cd976e0-1471033378842@3capp-gmx-bs27>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lino Sanfilippo wrote:
> You can either extend the refill function by one gfp_t parameter and then call it
> with GFP_KERNEL for the initial rx buffer allocation when the hw is brought up and
> then with GFP_ATOMIC for refilling in the NAPI handler. Or simply always use GFP_ATOMIC.
> In the latter case the additional parameter is not needed of course and you can
> use netdev_alloc_skb_ip_align() instead of __netdev_alloc_skb_ip_align().

I will change this to use netdev_alloc_skb_ip_align().

Thanks.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
