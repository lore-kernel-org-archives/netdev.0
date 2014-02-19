From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Fw:[Bug 70471] xfrm policy node will double unlink.
Date: Wed, 19 Feb 2014 12:43:26 +0100
Message-ID: <20140219114326.GE32371@secunet.com>
References: <tencent_0D7FA5355C7998793C100B23@qq.com>
 <20140218083737.GB32371@secunet.com>
 <tencent_4CE06FA903D8DCB54F951A30@qq.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>, alan <alan@lxorguk.ukuu.org.uk>
To: Xianpeng Zhao <673321875@qq.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:40834 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751277AbaBSLn3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Feb 2014 06:43:29 -0500
Content-Disposition: inline
In-Reply-To: <tencent_4CE06FA903D8DCB54F951A30@qq.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 19, 2014 at 10:07:14AM +0800, Xianpeng Zhao wrote:
> Hi Steffen,
> 
>       This problem is happened when running stress test; Very little chance can get this case.
> 
>       As you say, add a long time sleep in function xfrm_policy_bysel_ctx between __xfrm_policy_unlink and 
> xfrm_policy_kill, will reproduce this issue manually. 
> 
>       About my patch, I am not sure it is OK, because after it patched, the issue had reproduced once, but after some days test recently, have not reproduced again. 
> 
>       But I can make sure when __xfrm_policy_unlink find the node had been removed, return NULL instead of delete again will fix this problem.
> 
>       What's your suggestions?
> 

Please test the patch I've sent with the last mail.
Thanks!
