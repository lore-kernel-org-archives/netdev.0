From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH][net-next] xfrm: move the checking for old xfrm_policy
 hold_queue to beginning
Date: Tue, 5 May 2015 13:41:48 +0200
Message-ID: <20150505114148.GQ8928@secunet.com>
References: <1430385919-22030-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37157 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758453AbbEELlv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 07:41:51 -0400
Content-Disposition: inline
In-Reply-To: <1430385919-22030-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2015 at 05:25:19PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> if hold_queue of old xfrm_policy is NULL, return directly, then not need to
> run other codes, especially take the spin lock
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Also applied to ipsec-next, thanks a lot!
