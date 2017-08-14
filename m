From: David Miller <davem@davemloft.net>
Subject: Re: [patch v1 1/2] Allow Mellanox network vendor to be configured
 if only I2C bus is configured
Date: Sun, 13 Aug 2017 17:25:21 -0700 (PDT)
Message-ID: <20170813.172521.1720357048468458417.davem@davemloft.net>
References: <1502385112-103765-1-git-send-email-ohado@mellanox.com>
        <20170812143715.GN24282@mtr-leonro.local>
        <VI1PR05MB1262B06790B2738CE1C0F889C88F0@VI1PR05MB1262.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leon@kernel.org, netdev@vger.kernel.org, jiri@resnulli.us,
        saeedm@mellanox.com, vadimp@mellanox.com,
        system-sw-low-level@mellanox.com
To: ohado@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47528 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751367AbdHNAZY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2017 20:25:24 -0400
In-Reply-To: <VI1PR05MB1262B06790B2738CE1C0F889C88F0@VI1PR05MB1262.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ohad Oz <ohado@mellanox.com>
Date: Sun, 13 Aug 2017 15:26:56 +0000

> 
> 
>> -----Original Message-----
>> From: Leon Romanovsky [mailto:leon@kernel.org]
>> Sent: Saturday, August 12, 2017 5:37 PM
>> To: Ohad Oz <ohado@mellanox.com>
>> Cc: davem@davemloft.net; netdev@vger.kernel.org; jiri@resnulli.us; Saeed
>> Mahameed <saeedm@mellanox.com>; Vadim Pasternak
>> <vadimp@mellanox.com>; system-sw-low-level <system-sw-low-
>> level@mellanox.com>
>> Subject: Re: [patch v1 1/2] Allow Mellanox network vendor to be configured
>> if only I2C bus is configured
>> 
>> On Thu, Aug 10, 2017 at 05:11:51PM +0000, Ohad Oz wrote:
>> > Patch allows Mellanox devices on system with no PCI, but with I2C only.
>> >
>> 
>> Did you test mlx5 device on such system? Did it work for you?
> 
> Yes, I did. With PCI config set to disable mlx5 drivers are not built. 
> Only the following: 
> /build/drivers/net/Ethernet/mellanox/mlxsw/mlxsw_core.ko
> /build/drivers/net/Ethernet/mellanox /mlxsw/mlxsw_i2c.ko
> /build/drivers/net/Ethernet/mellanox /mlxsw/mlxsw_minimal.ko
> 
> While with both options on all drivers are built inc mlx5.

I'm not so sure he's interested if things build or not.

He's asking you if you actually used a Mellanox device with this
driver with PCI disabled and only I2C available.
