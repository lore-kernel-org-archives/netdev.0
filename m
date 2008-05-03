From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [Patch] (revised) net/xfrm/xfrm_policy.c: replace timer with
	delayed_work
Date: Sat, 3 May 2008 22:46:49 +0800
Message-ID: <20080503144647.GF3986@hack>
References: <alpine.LFD.1.10.0804302355120.2940@localhost.localdomain> <20080501011123.GA4060@gondor.apana.org.au> <alpine.LFD.1.10.0805021323470.3349@localhost.localdomain> <20080502.165455.24687234.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiyou.wangcong@gmail.com, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, akpm@osdl.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758983AbYECOnJ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080502.165455.24687234.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 02, 2008 at 04:54:55PM -0700, David Miller wrote:
>From: WANG Cong <xiyou.wangcong@gmail.com>
>Date: Fri, 2 May 2008 13:35:55 +0800 (CST)
>
>> 
>> As suggested by Herbert Xu, using workqueue is better than timer
>> for net/xfrm/xfrm_policy.c, so replace them with delayed_work.
>> And due to this change, we have to disable BH when trying to
>> lock.
>> 
>> Note that, this patch is not fully tested, so should be
>> in -mm first.
>> 
>> Signed-off-by: WANG Cong <wangcong@zeuux.org>
>
>Please let me know when these two patches have gotten some
>good testing.

Thanks for your comments, David!

I thought it can go into -mm so that many other people can help
me to test it. Since I didn't have the IPSec environment. ;(

I will try if I can set up one, then test it.

Thanks.
