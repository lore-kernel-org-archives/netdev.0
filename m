From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: phy: resume phydev when PHY_RESUMING
Date: Tue, 13 May 2014 22:51:05 +0400
Message-ID: <53726999.4050103@cogentembedded.com>
References: <1399972998-21772-1-git-send-email-zhangfei.gao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiancheng Xue <xuejiancheng@huawei.com>
To: Zhangfei Gao <zhangfei.gao@linaro.org>,
	sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:55326 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754446AbaEMSvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 14:51:06 -0400
Received: by mail-lb0-f180.google.com with SMTP id p9so609866lbv.39
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 11:51:04 -0700 (PDT)
In-Reply-To: <1399972998-21772-1-git-send-email-zhangfei.gao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/13/2014 01:23 PM, Zhangfei Gao wrote:

> Commit be9dad1f9f26604fb suspend phydev when going to HALTED.

    Please also specify that commit's summary line in parens.

> However not to resume phydev when going to RESUMING.
> BMCR_PDOWN remains set "ifconfig eth0 down" -> "ifconfig eth0 up".
> Unless phy_attach_direct is called in open function.

> Fix the issue via phy_resume in PHY_RESUMING

> Signed-off-by: Jiancheng Xue <xuejiancheng@huawei.com>
> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>

WBR, Sergei
