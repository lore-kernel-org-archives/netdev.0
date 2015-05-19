From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: optimise to search the inexact policy list
Date: Tue, 19 May 2015 13:14:50 +0200
Message-ID: <20150519111448.GL8928@secunet.com>
References: <1431573419-31253-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <rongqing.li@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49671 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755195AbbESLO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 07:14:58 -0400
Content-Disposition: inline
In-Reply-To: <1431573419-31253-1-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 14, 2015 at 11:16:59AM +0800, rongqing.li@windriver.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> The policies are organized into list by priority ascent of policy,
> so it is unnecessary to continue to loop the policy if the priority
> of current looped police is larger than or equal priority which is
> from the policy_bydst list.
> 
> This allows to match policy with ~0U priority in inexact list too.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied to ipsec-next, thanks a lot!
