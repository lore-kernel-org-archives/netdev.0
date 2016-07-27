From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 11/15] ethernet: renesas: ravb_main: add missing
 of_node_put after calling of_parse_phandle
Date: Wed, 27 Jul 2016 13:50:28 +0300
Message-ID: <6d513cae-c07c-540f-915d-0a95f2a36ffe@cogentembedded.com>
References: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
 <1469586048-15697-12-git-send-email-peter.chen@nxp.com>
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
Received: from mail-lf0-f43.google.com ([209.85.215.43]:34099 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930AbcG0Kud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 06:50:33 -0400
Received: by mail-lf0-f43.google.com with SMTP id l69so24434982lfg.1
        for <netdev@vger.kernel.org>; Wed, 27 Jul 2016 03:50:32 -0700 (PDT)
In-Reply-To: <1469586048-15697-12-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/27/2016 5:20 AM, Peter Chen wrote:

> of_node_put needs to be called when the device node which is got
> from of_parse_phandle has finished using.
>
> Signed-off-by: Peter Chen <peter.chen@nxp.com>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
