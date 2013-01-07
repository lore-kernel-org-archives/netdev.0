From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH] ah4/esp4: set transport header correctly for IPsec
 tunnel mode.
Date: Mon, 7 Jan 2013 14:00:43 +0100
Message-ID: <20130107130043.GS18940@secunet.com>
References: <1356682036-25642-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55431 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754384Ab3AGNAq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2013 08:00:46 -0500
Content-Disposition: inline
In-Reply-To: <1356682036-25642-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 28, 2012 at 04:07:16PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> IPsec tunnel does not set ECN field to CE in inner header when
> the ECN field in the outer header is CE, and the ECN field in
> the inner header is ECT(0) or ECT(1).
> 
> The cause is ipip_hdr() does not return the correct address of
> inner header since skb->transport-header is not the inner header
> after esp_input_done2(), or ah_input().
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
> I know this bug, but no lab to verify if my patch is correct,
> hope netdev experts can inspect this patch carefully, if this
> can be accepted, I will do same fix for ah6/esp6

This looks ok to me, please submit the ipv6 side too.

Thanks!
