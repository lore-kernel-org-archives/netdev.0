From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 2/4] net: sched: introduce per-egress action
 device callbacks
Date: Tue, 10 Oct 2017 16:31:52 +0200
Message-ID: <20171010143152.GG2033@nanopsycho>
References: <20171010073016.3682-1-jiri@resnulli.us>
 <20171010073016.3682-3-jiri@resnulli.us>
 <063D6719AE5E284EB5DD2968C1650D6DD008ED67@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "saeedm@mellanox.com" <saeedm@mellanox.com>,
        "matanb@mellanox.com" <matanb@mellanox.com>,
        "leonro@mellanox.com" <leonro@mellanox.com>,
        "mlxsw@mellanox.com" <mlxsw@mellanox.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:57055 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932119AbdJJOby (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 10:31:54 -0400
Received: by mail-wm0-f51.google.com with SMTP id l68so5920104wmd.5
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 07:31:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD008ED67@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 10, 2017 at 03:31:59PM CEST, David.Laight@ACULAB.COM wrote:
>From: Jiri Pirko
>> Sent: 10 October 2017 08:30
>> Introduce infrastructure that allows drivers to register callbacks that
>> are called whenever tc would offload inserted rule and specified device
>> acts as tc action egress device.
>
>How does a driver safely unregister a callback?
>(to avoid a race with the callback being called.)
>
>Usually this requires a callback in the context that makes the
>notification callbacks indicating that no more such callbacks
>will be made.

rtnl is your answer. It is being held during register/unregister/cb
