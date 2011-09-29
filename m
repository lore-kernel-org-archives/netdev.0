From: "Yan, Zheng " <yanzheng@21cn.com>
Subject: Re: [PATCH] Ipv6: Delete rcu_read_lock
Date: Thu, 29 Sep 2011 16:52:38 +0800
Message-ID: <CAAM7YAmwXyORpFWhthX4iSEkBp7OANnZ8tHruEyN62Z3mnOdLw@mail.gmail.com>
References: <1317282414-13368-1-git-send-email-rongqing.li@windriver.com>
	<CAAM7YAnE4w4y6YWWxk0QGOX8Y6AZQHHQBuVMoRuSm=GtALAx=Q@mail.gmail.com>
	<4E842B93.3010203@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Rongqing Li <rongqing.li@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:55265 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754894Ab1I2Iwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 04:52:39 -0400
Received: by vws1 with SMTP id 1so241910vws.19
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2011 01:52:38 -0700 (PDT)
In-Reply-To: <4E842B93.3010203@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 29, 2011 at 4:25 PM, Rongqing Li <rongqing.li@windriver.com> wrote:
> On 09/29/2011 04:16 PM, Yan, Zheng wrote:
>>
>> I think the rcu_read_lock protects in6_dev->nd_parms.
>>
> It can not protect in6_dev->nd_parms.
>
> rcu_read_lock protects the data which is accessed by rcu_XXX,
>

I'm confused, why does neigh_parms_release() use call_rcu() to release nd_parms.
