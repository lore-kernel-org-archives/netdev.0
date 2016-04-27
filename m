From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: Add Qualcomm IPC router
Date: Wed, 27 Apr 2016 14:55:33 -0400 (EDT)
Message-ID: <20160427.145533.281908074397879897.davem@davemloft.net>
References: <1461736085-24862-1-git-send-email-bjorn.andersson@linaro.org>
	<20160427.122242.1614940676503935894.davem@davemloft.net>
	<20160427171445.GO3202@tuxbot>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, courtney.cavin@sonymobile.com,
	bjorn.andersson@sonymobile.com
To: bjorn.andersson@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160427171445.GO3202@tuxbot>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Andersson <bjorn.andersson@linaro.org>
Date: Wed, 27 Apr 2016 10:14:45 -0700

> On Wed 27 Apr 09:22 PDT 2016, David Miller wrote:
> 
>> This code can now only be build tested on ARCH_QCOM architectures, and
>> that's a serious negative downside.
> 
> For normal usage the QRTR_SMD doesn't make much sense to be selectable
> unless QCOM_SMD is compiled in, but I can fix up the QCOM_SMD exports
> and slap a COMPILE_TEST on it.
> 
> 
> Looking at it again, we already have the conditional for QRTR and the OF
> code in the driver went away a while back, so we're down to something
> like:
> 
> 	depends on QCOM_SMD || COMPILE_TEST

If that's enough to make it work, feel free to spin as a series a patch that
does the Kconfig bits and then the patch that adds the IPC protocol.
