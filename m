From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [Patch]net/xfrm/xfrm_policy.c: replace timer with delayed_work
Date: Fri, 2 May 2008 13:21:24 +0800 (CST)
Message-ID: <alpine.LFD.1.10.0805021319200.3349@localhost.localdomain>
References: <20080216.235534.237382205.xiyou.wangcong@gmail.com> <20080427011809.GA662@gondor.apana.org.au> <20080428.225312.58450957.xiyou.wangcong@gmail.com> <20080428151342.GA12007@gondor.apana.org.au> <alpine.LFD.1.10.0804302355120.2940@localhost.localdomain>
 <20080501011123.GA4060@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: WANG Cong <xiyou.wangcong@gmail.com>, linux-kernel@vger.kernel.org,
	davem@davemloft.net, akpm@osdl.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759402AbYEBFRj@vger.kernel.org>
In-Reply-To: <20080501011123.GA4060@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 1 May 2008, Herbert Xu wrote:

> On Thu, May 01, 2008 at 12:06:55AM +0800, WANG Cong wrote:
>> 
>> Hi, Herbert.
>> 
>> I referenced the book Linux Device Drivers, it is said that
>> the work function in workqueue can sleep, that is to say, it only
>> works in process context, so we don't need the disable the lock
>> in softirq, which is interrupt context, right?
>
> Because it can sleep, you must disable BH for locks that can
> be taken on the softirq path as otherwise a softirq can come
> in, try to take the lock again and dead-lock.

Yes, I was an idiot.

I will resend the revised patches right now.
