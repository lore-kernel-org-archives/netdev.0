From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] ah6/esp6: set transport header correctly for IPsec
 tunnel mode.
Date: Fri, 11 Jan 2013 08:54:39 +0100
Message-ID: <20130111075439.GW18940@secunet.com>
References: <1357630872-1942-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34424 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753456Ab3AKHyl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 02:54:41 -0500
Content-Disposition: inline
In-Reply-To: <1357630872-1942-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 08, 2013 at 03:41:12PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> IPsec tunnel does not set ECN field to CE in inner header when
> the ECN field in the outer header is CE, and the ECN field in
> the inner header is ECT(0) or ECT(1).
> 
> The cause is ipip6_hdr() does not return the correct address of
> inner header since skb->transport-header is not the inner header
> after esp6_input_done2(), or ah6_input().
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Also applied, thanks a lot!
