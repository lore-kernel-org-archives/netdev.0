From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/5] e1000e: do not toggle LANPHYPC value bit when PHY
 reset is blocked
Date: Mon, 15 Dec 2014 15:01:48 +0300
Message-ID: <548ECDAC.90207@cogentembedded.com>
References: <1418632754-16698-1-git-send-email-Yanjun.Zhu@windriver.com> <1418632754-16698-4-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Zhu Yanjun <zyjzyj2000@gmail.com>, netdev@vger.kernel.org, w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:53185 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496AbaLOMBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 07:01:49 -0500
Received: by mail-lb0-f175.google.com with SMTP id u10so8816451lbd.6
        for <netdev@vger.kernel.org>; Mon, 15 Dec 2014 04:01:48 -0800 (PST)
In-Reply-To: <1418632754-16698-4-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/15/2014 11:39 AM, Zhu Yanjun wrote:

> 2.6.x kernels require a similar logic change as commit b7d6e335
> [e1000e: do not toggle LANPHYPC value bit when PHY reset is blocked]
> introduces for newer kernels.

    Hm, so is this patch to 2.6.x-stable kernels or a recent kernel?
If the former, you should follow the rules in 
Documentation/stable_kernel_rules.txt.

> When PHY reset is intentionally blocked on 82577/8/9, do not toggle the
> LANPHYPC value bit (essentially performing a hard power reset of the
> device) otherwise the PHY can be put into an unknown state.

> Cleanup whitespace in the same function.

> [yanjun.zhu: whitespace remains unchanged]

> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>

    So, is this your patch, or Bruce's? If the latter, you should add:

From: Bruce Allan <bruce.w.allan@intel.com>

at the start of the change log.

> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>

WBR, Sergei
