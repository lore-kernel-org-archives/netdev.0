From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] gianfar: ensure ECNTRL[R100] is cleared on link state change
Date: Tue, 6 Jan 2009 14:56:25 -0600
Message-ID: <8E33B4C2-F1E3-4C64-86E4-6EAA4C7151C5@freescale.com>
References: <1231275171-21388-1-git-send-email-galak@kernel.crashing.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	davem@davemloft.net, Leo Li <leo@rock.ap.freescale.net>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:44902 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755AbZAFU46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 15:56:58 -0500
In-Reply-To: <1231275171-21388-1-git-send-email-galak@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 6, 2009, at 2:52 PM, Kumar Gala wrote:

> From: Leo Li <leo@rock.ap.freescale.net>
>
> When changing the link between 100Mbps and 1Gbps in SGMII mode it was
> found out that the link would stop working.  The issue is that  
> ECNTRL[R100]
> needs to be cleared when in 1Gbps mode.  Older reference manuals  
> didn't
> require the explicitly clearing but has since been found it that it is
> needed.
>
> Signed-off-by: Li Yang <leoli@freescale.com>
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>

Acked-by: Andy Fleming <afleming@freescale.com>

