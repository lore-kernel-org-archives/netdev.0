From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH net-next v3 0/4] net: mvneta: improve rx/tx performance
Date: Tue, 21 Feb 2017 17:35:20 +0100
Message-ID: <CAPv3WKekgKBNmmc0DhcFy5DW=5nmuFjmcAsAh45dhhnCEk4bLw@mail.gmail.com>
References: <20170220125344.3555-1-jszhang@marvell.com> <877f4laqog.fsf@free-electrons.com>
 <20170221123726.2db7db19@xhacker> <20170221.111602.860315087619854954.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        =?UTF-8?Q?Gregory_Cl=C3=A9ment?=
        <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Arnd Bergmann <arnd@arndb.de>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170221.111602.860315087619854954.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jisheng,

2017-02-21 17:16 GMT+01:00 David Miller <davem@davemloft.net>:
> From: Jisheng Zhang <jszhang@marvell.com>
> Date: Tue, 21 Feb 2017 12:37:40 +0800
>
>> Thanks for your review.
>>
>> The measurement is simple: record how much time we spent in mvneta_rx_swbm()
>> for receiving 1GB data, something as below:
>
> Please use a standard tool for measuring performance, rather than profiling
> the driver and trying to derive numbers that way.

If possible in your setup, I suggest pushing 64B (and other sizes)
packets uni or bidirectionally via 2 ports in L2 bridge mode. It's a
good stress test, you'd get some meaningful numbers (also check cpu
consumption with mpstat in the meantime).

Best regards,
Marcin
