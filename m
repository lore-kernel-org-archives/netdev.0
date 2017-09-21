From: Chris Lew <clew@codeaurora.org>
Subject: Re: [PATCH 1/7] net: qrtr: Invoke sk_error_report() after setting
 sk_err
Date: Thu, 21 Sep 2017 11:27:26 -0700
Message-ID: <c7b2cee7-06d2-b3db-07dc-cdf6c850c12b@codeaurora.org>
References: <20170907060329.32402-1-bjorn.andersson@linaro.org>
 <20170907060329.32402-2-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org
To: Bjorn Andersson <bjorn.andersson@linaro.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20170907060329.32402-2-bjorn.andersson@linaro.org>
Content-Language: en-US
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 9/6/2017 11:03 PM, Bjorn Andersson wrote:
> Rather than manually waking up any context sleeping on the sock to
> signal an error we should call sk_error_report(). This has the added
> benefit that in-kernel consumers can override this notificatino with
> its own callback.
> 

Typo with notification.

Thanks,
Chris

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
a Linux Foundation Collaborative Project
