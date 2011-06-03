From: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to physical device (v2)
Date: Fri, 3 Jun 2011 17:59:21 +0300
Message-ID: <201106031759.22073.vitas@nppfactor.kiev.ua>
References: <1307037799-32315-1-git-send-email-nhorman@tuxdriver.com> <1307107607-3015-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.cyfra.ua ([62.80.160.182]:55631 "EHLO mx3.cyfra.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754107Ab1FCO7t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2011 10:59:49 -0400
In-Reply-To: <1307107607-3015-1-git-send-email-nhorman@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 03 June 2011 16:26:47 Neil Horman wrote:
[...]
> +	/*
> +	 *restore the origional mapping
 Style and spelling nits, shouldn't it be:
* Restore the original mapping
> +	 */
> +	skb_set_queue_mapping(skb, (u16)skb->cb[0]);
As already pointed by Ben, it should be ((u16 *)skb->cb)[0]
[...]
> +	/*
> + 	 * Save the origional txq to restore before passing to the driver
Spelling: original
> + 	 */
> +	skb->cb[0] = txq;
As already pointed by Ben, it should be ((u16 *)skb->cb)[0]

-- 
Vitalii Demianets
