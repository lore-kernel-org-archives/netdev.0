From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: [PATCH net-next v3 0/4] net: mvneta: improve rx/tx performance
Date: Fri, 24 Feb 2017 19:56:48 +0800
Message-ID: <20170224195648.219d6b50@xhacker>
References: <20170220125344.3555-1-jszhang@marvell.com>
        <877f4laqog.fsf@free-electrons.com>     <20170221123726.2db7db19@xhacker>
        <20170221.111602.860315087619854954.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <gregory.clement@free-electrons.com>,
        <thomas.petazzoni@free-electrons.com>, <arnd@arndb.de>,
        <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <mw@semihalf.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016f401.pphosted.com ([67.231.148.174]:60350 "EHLO
        mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751080AbdBXMB6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 07:01:58 -0500
In-Reply-To: <20170221.111602.860315087619854954.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Marcin,

On Tue, 21 Feb 2017 11:16:02 -0500 David Miller wrote:

> From: Jisheng Zhang <jszhang@marvell.com>
> Date: Tue, 21 Feb 2017 12:37:40 +0800
> 
> > Thanks for your review.
> > 
> > The measurement is simple: record how much time we spent in mvneta_rx_swbm()
> > for receiving 1GB data, something as below:  
> 
> Please use a standard tool for measuring performance, rather than profiling
> the driver and trying to derive numbers that way.

Got your point. I will try to get performance with standard tool and cook a
v4 once rc1 is released.

Thanks,
Jisheng
