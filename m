From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] [11/11] pasemi_mac: enable iommu support
Date: Wed, 03 Oct 2007 13:47:17 -0400
Message-ID: <4703D5A5.1080204@pobox.com>
References: <20071002212421.GA2282@lixom.net> <20071002212818.GL2282@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53386 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751995AbXJCRrT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 13:47:19 -0400
In-Reply-To: <20071002212818.GL2282@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson wrote:
> pasemi_mac: use buffer index pointer in clean_rx()
> 
> Use the new features in B0 for buffer ring index on the receive side. This
> means we no longer have to search in the ring for where the buffer
> came from.
> 
> Also cleanup the RX cleaning side a little, while I was at it.
> 
> Note: Pre-B0 hardware is no longer supported, and needs a pile of other
> workarounds that are not being submitted for mainline inclusion. So the
> fact that this breaks old hardware is not a problem at this time.
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

You sent patch #10 against as patch #11 :)


