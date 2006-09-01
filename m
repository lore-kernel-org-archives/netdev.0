From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH] xfrm: remove xerr_idxp from __xfrm_policy_check()
Date: Fri, 01 Sep 2006 16:15:39 +0900
Message-ID: <44F7DE1B.9060503@linux-ipv6.org>
References: <Pine.LNX.4.64.0609010054280.22977@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:19334 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S964882AbWIAHPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 03:15:35 -0400
To: James Morris <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0609010054280.22977@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


James Morris wrote:
> It seems that during the MIPv6 respin, some code which was originally 
> conditionally compiled around CONFIG_XFRM_ADVANCED was accidently left in 
> after the config option was removed.
> 
> This patch removes an extraneous pointer (xerr_idxp) which is no longer 
> needed.
> 
> Please review & apply.
> 
> Signed-off-by: James Morris <jmorris@namei.org>

It seems fine for me.
David, please apply it.


-- 
Masahide NAKAMURA
