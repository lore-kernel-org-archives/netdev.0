From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 02/11] ixgbe: clean up checkpatch warnings about
 CODE_INDENT and LEADING_SPACE
Date: Wed, 14 May 2014 09:25:57 -0700
Message-ID: <1400084757.19788.12.camel@joe-AO725>
References: <1400057663-4578-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1400057663-4578-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jacob Keller <jacob.e.keller@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0215.hostedemail.com ([216.40.44.215]:41726 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754219AbaENQ0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 12:26:03 -0400
In-Reply-To: <1400057663-4578-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-14 at 01:54 -0700, Jeff Kirsher wrote:

trivial note:

> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
[]
> @@ -362,7 +362,7 @@ struct ixgbe_ring_container {
>  	for (pos = (head).ring; pos != NULL; pos = pos->next)
>  
>  #define MAX_RX_PACKET_BUFFERS ((adapter->flags & IXGBE_FLAG_DCB_ENABLED) \
> -                              ? 8 : 1)
> +			      ? 8 : 1)

My preference would be to use a form that keeps the
actual statement on a single line like:

#define MAX_RX_PACKET_BUFFERS					\
	(adapter->flags & IXGBE_FLAG_DCB_ENABLED ? 8 : 1)

or if you really like parentheses

#define MAX_RX_PACKET_BUFFERS					\
	((adapter->flags & IXGBE_FLAG_DCB_ENABLED) ? 8 : 1)
