From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] net/mlx4_core: Fix Oops on reboot when SRIOV VFs
 are probed into the Host
Date: Sun, 01 Jun 2014 20:41:31 +0400
Message-ID: <538B57BB.5090000@cogentembedded.com>
References: <1401619783-23659-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	weiyang@linux.vnet.ibm.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:55472 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbaFAQld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 12:41:33 -0400
Received: by mail-la0-f52.google.com with SMTP id s18so61665lam.25
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 09:41:32 -0700 (PDT)
In-Reply-To: <1401619783-23659-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/01/2014 02:49 PM, Or Gerlitz wrote:

> From: Jack Morgenstein <jackm@dev.mellanox.co.il>

> Commit befdf89 did not take into account the case where the Host

    Please also specify that commit's summary line in parens.

> driver is being unloaded. In this case, pci_get_drvdata for the VF
> remove_one call may return NULL, so that dereferencing the priv
> struct results in a kernel oops.

> The fix is to also test that the dev pointer returned by
> pci_get_drvdata is non-NULL.

> Fixes: befdf89 ("preserve pcd_dev_data after __mlx4_remove_one()")
> Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

WBR, Sergei
