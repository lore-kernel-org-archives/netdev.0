From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch net-next 2/4] net: sched: introduce per-egress action
 device callbacks
Date: Tue, 10 Oct 2017 13:31:59 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD008ED67@AcuExch.aculab.com>
References: <20171010073016.3682-1-jiri@resnulli.us>
 <20171010073016.3682-3-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "saeedm@mellanox.com" <saeedm@mellanox.com>,
        "matanb@mellanox.com" <matanb@mellanox.com>,
        "leonro@mellanox.com" <leonro@mellanox.com>,
        "mlxsw@mellanox.com" <mlxsw@mellanox.com>
To: 'Jiri Pirko' <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.195]:57363 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932176AbdJJNcJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 09:32:09 -0400
In-Reply-To: <20171010073016.3682-3-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko
> Sent: 10 October 2017 08:30
> Introduce infrastructure that allows drivers to register callbacks that
> are called whenever tc would offload inserted rule and specified device
> acts as tc action egress device.

How does a driver safely unregister a callback?
(to avoid a race with the callback being called.)

Usually this requires a callback in the context that makes the
notification callbacks indicating that no more such callbacks
will be made.

	David
