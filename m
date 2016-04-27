From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: Add Qualcomm IPC router
Date: Wed, 27 Apr 2016 12:22:42 -0400 (EDT)
Message-ID: <20160427.122242.1614940676503935894.davem@davemloft.net>
References: <1461736085-24862-1-git-send-email-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, courtney.cavin@sonymobile.com,
	bjorn.andersson@sonymobile.com
To: bjorn.andersson@linaro.org
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <1461736085-24862-1-git-send-email-bjorn.andersson@linaro.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Andersson <bjorn.andersson@linaro.org>
Date: Tue, 26 Apr 2016 22:48:05 -0700

> +	rc = qcom_smd_send(qdev->channel, skb->data, skb->len);

I truly dislike adding networking protocols that depend upon some
piece of infrastructure that only some platforms can enable, it's even
worse when that set of platforms doesn't intersect with x86-64.

When you do things like this, it's quite hard to make protocol wide
changes to APIs because build testing becomes an issue.

This code can now only be build tested on ARCH_QCOM architectures, and
that's a serious negative downside.
