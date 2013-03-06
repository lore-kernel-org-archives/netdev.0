From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: Re: [PATCH 1/1] net: ipv4: Remove redundant NULL check
Date: Wed, 6 Mar 2013 08:45:32 +0530
Message-ID: <CAK9yfHwSyBBp7BEztRaKowJFsMebXtDq=CdQJCBJDyZZb84XoA@mail.gmail.com>
References: <1362482829-10455-1-git-send-email-sachin.kamat@linaro.org>
	<20130305.144052.577951922981506984.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:58284 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217Ab3CFDPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 22:15:33 -0500
Received: by mail-ob0-f170.google.com with SMTP id wc20so3231689obb.1
        for <netdev@vger.kernel.org>; Tue, 05 Mar 2013 19:15:32 -0800 (PST)
In-Reply-To: <20130305.144052.577951922981506984.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6 March 2013 01:10, David Miller <davem@davemloft.net> wrote:
> From: Sachin Kamat <sachin.kamat@linaro.org>
> Date: Tue,  5 Mar 2013 16:57:09 +0530
>
>> kfree on a null pointer is a NO-OP. Hence null check is not necessary.
>>
>> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
>
> Unnecessary writes to the socket struct should be avoided, as it
> generates unnecessary write traffic to the L2 cache.

Sounds reasonable.

>
> I'm not applying this.

Ok. No problem.
