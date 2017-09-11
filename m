From: Kishon Vijay Abraham I <kishon@ti.com>
Subject: Re: [PATCH net] phy: mvebu-cp110: checking for NULL instead of
 IS_ERR()
Date: Mon, 11 Sep 2017 12:54:47 +0530
Message-ID: <1bc9c815-08ba-1095-eb6d-a753b3d0c755@ti.com>
References: <20170908103137.zck6bw66sge4fhua@mwanda>
 <20170908.210905.626281012369795940.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <antoine.tenart@free-electrons.com>, <netdev@vger.kernel.org>,
        <kernel-janitors@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170908.210905.626281012369795940.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Saturday 09 September 2017 09:39 AM, David Miller wrote:
> From: Dan Carpenter <dan.carpenter@oracle.com>
> Date: Fri, 8 Sep 2017 13:31:37 +0300
> 
>> devm_ioremap_resource() never returns NULL, it only returns error
>> pointers so this test needs to be changed.
>>
>> Fixes: d0438bd6aa09 ("phy: add the mvebu cp110 comphy driver")
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>> ---
>> This driver apparently is going through the net tree, but netdev isn't
>> listed as handling it in MAINTAINERS.  Kishon, do you know what's up
>> with that?

I've reviewed this driver and sometimes the PHY drivers gets merged along with
their consumer driver (In this case mvpp2 ethernet driver). But after it's
merged, all further fixes and features go via linux-phy tree (mostly).
> 
> Yeah let's sort this out before I apply this fix to my tree.

I'll take this fix in linux-phy tree after -rc1 is tagged if that's okay with you.

Thanks
Kishon
