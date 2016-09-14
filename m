From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 3/9] net: ethernet: ti: cpts: rework
 initialization/deinitialization
Date: Wed, 14 Sep 2016 23:59:26 +0300
Message-ID: <efd98aa5-725a-86c1-88c9-e10350ff1b43@ti.com>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-4-grygorii.strashko@ti.com>
 <20160914135214.GA28592@localhost.localdomain>
 <606f7cfc-aa34-528b-df04-7a60a9695425@ti.com> <20160914203217.GD12195@netboy>
 <c0aac71d-2033-f210-5494-15399b477e37@ti.com> <20160914205223.GF12195@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, WingMan Kwok <w-kwok2@ti.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160914205223.GF12195@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/14/2016 11:52 PM, Richard Cochran wrote:
> On Wed, Sep 14, 2016 at 11:37:45PM +0300, Grygorii Strashko wrote:
>> The problem is that if cpts not initialized than pinter on 
>> cpts (in consumer/parent driver - NETCP) will be NULL.
> 
> You made that problem with your "clean up" in this series.
> Previously, cpts was always allocated.

not exactly - it was allocated in CPSW .probe() manually, 
in without this re-work it has to be allocated in NTCP the
same way - manually. So, checks we are discussing here will be still
present, but they will need to be done in CPSW/NETCP drivers -
just one level up and duplicated in both these drivers.

> 
>> So, rx_enable will be unaccessible and cause crash :(
> 
> So just make sure cpts is initialized.

OK. I'll update code this way.

-- 
regards,
-grygorii
