From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] e1000 in linux-3.18.0: a potential bug
Date: Sat, 20 Dec 2014 16:27:50 +0300
Message-ID: <54957956.30803@cogentembedded.com>
References: <000d01d01c29$a9edb870$fdc92950$@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net
To: Jia-Ju Bai <baijiaju1990@163.com>, todd.fujinaka@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:57896 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752812AbaLTN1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Dec 2014 08:27:52 -0500
Received: by mail-la0-f41.google.com with SMTP id hv19so2129302lab.14
        for <netdev@vger.kernel.org>; Sat, 20 Dec 2014 05:27:51 -0800 (PST)
In-Reply-To: <000d01d01c29$a9edb870$fdc92950$@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/20/2014 10:50 AM, Jia-Ju Bai wrote:

> I have actually tested e1000 driver on the real hardware(Intel 82540EM PCI
> Gigabit Ethernet Controller), and find a potential bug:
> The target file is drivers/net/ethernet/intel/e1000/e1000_main.c, which is
> used to build e1000.ko.

> (1) In the normal process, netif_napi_add is called in e1000_probe, but
> netif_napi_del is not called in e1000_remove. However, many other ethernet
> card drivers call them in pairs, even in the error handling paths, such as
> r8169 and igb.

> Meanwhile, I also write the patch to fix the bug. I have run the patch on
> the hardware, it can work normally and fix the above bug.

    You didn't sign off on your patch, so it can't be applied.

WBR, Sergei
