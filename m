From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH net] tg3: update rx_jumbo_pending ring param only when
 jumbo frames are enabled
Date: Thu, 17 Apr 2014 10:47:32 -0700
Message-ID: <1397756852.13168.42.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1397739068-14240-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:17934 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725AbaDQRri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2014 13:47:38 -0400
In-Reply-To: <1397739068-14240-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-04-17 at 14:51 +0200, Ivan Vecera wrote: 
> The patch fixes a problem with dropped jumbo frames after usage of
> 'ethtool -G ... rx'.
> 
> Scenario:
> 1. ip link set eth0 up
> 2. ethtool -G eth0 rx N # <- This zeroes rx-jumbo
> 3. ip link set mtu 9000 dev eth0
> 
> The ethtool command set rx_jumbo_pending to zero so any received jumbo
> packets are dropped and you need to use 'ethtool -G eth0 rx-jumbo N'
> to workaround the issue.
> The patch changes the logic so rx_jumbo_pending value is changed only if
> jumbo frames are enabled (MTU > 1500).
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Acked-by: Michael Chan <mchan@broadcom.com>
