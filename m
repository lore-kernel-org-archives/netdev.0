From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH 2/2] ucc_geth: use rx-clock-name and tx-clock-name device
 tree properties
Date: Wed, 12 Dec 2007 09:19:41 -0600
Message-ID: <475FFC0D.8040305@freescale.com>
References: <11967166791607-git-send-email-timur@freescale.com> <1196716680381-git-send-email-timur@freescale.com> <1196716685975-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:34487 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636AbXLLPTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 10:19:51 -0500
In-Reply-To: <1196716685975-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timur Tabi wrote:
> Updates the ucc_geth device driver to check the new rx-clock-name and
> tx-clock-name properties first.  If present, it uses the new function
> qe_clock_source() to obtain the clock source.  Otherwise, it checks the
> deprecated rx-clock and tx-clock properties.
> 
> Update the device trees for 832x, 836x, and 8568 to contain the new property
> names only.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>

If there are no objections, I'd like this patch to be pulled into 2.6.25.  Thanks.

-- 
Timur Tabi
Linux kernel developer at Freescale
