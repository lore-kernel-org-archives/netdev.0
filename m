From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 12/15] ethernet: renesas: sh_eth: add missing of_node_put
 after calling of_parse_phandle
Date: Wed, 27 Jul 2016 13:51:47 +0300
Message-ID: <67e12efb-b04e-d61e-a1b0-aee03197233c@cogentembedded.com>
References: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
 <1469586048-15697-13-git-send-email-peter.chen@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vbridger@opensource.altera.com,
	isubramanian@apm.com, kchudgar@apm.com, yisen.zhuang@huawei.com,
	salil.mehta@huawei.com, thomas.petazzoni@free-electrons.com,
	peppe.cavallaro@st.com, alexandre.torgue@st.com,
	mugunthanvnm@ti.com, tremyfr@gmail.com, wxt@rock-chips.com,
	arnd@arndb.de, david.daney@cavium.com, huangdaode@hisilicon.com,
	jszhang@marvell.com
To: Peter Chen <peter.chen@nxp.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:36527 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbcG0Kvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 06:51:51 -0400
Received: by mail-lf0-f48.google.com with SMTP id g62so24370968lfe.3
        for <netdev@vger.kernel.org>; Wed, 27 Jul 2016 03:51:50 -0700 (PDT)
In-Reply-To: <1469586048-15697-13-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/27/2016 5:20 AM, Peter Chen wrote:

> of_node_put needs to be called when the device node which is got
> from of_parse_phandle has finished using.
>
> Signed-off-by: Peter Chen <peter.chen@nxp.com>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
