From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] net: cpmac: fix in debug messages
Date: Thu, 10 Jul 2014 21:31:58 +0400
Message-ID: <53BECE0E.3030209@cogentembedded.com>
References: <1404986378-28555-1-git-send-email-varkabhadram@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, linux@rainbow-software.org, balbi@ti.com,
	george.cherian@ti.com, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: varkabhadram@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:59996 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbaGJRbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 13:31:51 -0400
Received: by mail-la0-f52.google.com with SMTP id gl10so1102116lab.25
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 10:31:49 -0700 (PDT)
In-Reply-To: <1404986378-28555-1-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07/10/2014 01:59 PM, varkabhadram@gmail.com wrote:

> From: Varka Bhadram <varkab@cdac.in>

> This patch fix the debug message format. This patch changes to the
> commit f160a2d0b524eeebd97a68e2fbb59fad4cdd3fee: net: cpmac: dynamic debug fixes

> When we use pr_debug()/netdev_dbg() new lines are inserting in b/w
> the values. The format when i use the printk()

    Please use pr_cont() instead.

> These formats used in skb dump and reg dump. This functions
> called from the entire code. So this will be enabled all the lines.

> Signed-off-by: Varka Bhadram <varkab@cdac.in>

WBR, Sergei
