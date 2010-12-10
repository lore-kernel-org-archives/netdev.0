From: Joe Perches <joe@perches.com>
Subject: Re: [net-next-2.6 25/27] e1000e: static analysis tools complain of
 a possible null ptr p dereference
Date: Fri, 10 Dec 2010 04:44:50 -0800
Message-ID: <1291985090.24978.17.camel@Joe-Laptop>
References: <1291975585-30576-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1291975585-30576-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, davem@davemleft.org,
	Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2495 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755735Ab0LJMow (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 07:44:52 -0500
In-Reply-To: <1291975585-30576-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-12-10 at 02:06 -0800, Jeff Kirsher wrote:
> diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
[]
> +		default:
> +			data[i] = 0;
> +			continue;
> +			break;

Using

	continue;
	break;

is odd and unhelpful.
Just continue; is sufficient and clear.


