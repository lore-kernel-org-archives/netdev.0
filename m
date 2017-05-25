From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 0/8] mlxsw: Support firmware flash
Date: Thu, 25 May 2017 08:15:12 +0200
Message-ID: <20170525061512.GA1909@nanopsycho>
References: <20170523195630.6460-1-jiri@resnulli.us>
 <20170524.163328.672261790569871029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, idosch@mellanox.com, yotamg@mellanox.com,
        mlxsw@mellanox.com, Yuval.Mintz@cavium.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:34192 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162865AbdEYGPP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 02:15:15 -0400
Received: by mail-wr0-f181.google.com with SMTP id j27so12557187wre.1
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 23:15:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170524.163328.672261790569871029.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, May 24, 2017 at 10:33:28PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Tue, 23 May 2017 21:56:22 +0200
>
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Add support for device firmware flash on mlxsw spectrum. The firmware files
>> are expected to be in the Mellanox Firmware Archive version 2 (MFA2)
>> format.
>> 
>> The firmware flash is triggered on driver initialization time if the device
>> firmware version does not meet the minimum firmware version supported by
>> the driver.
>> 
>> Currently, to activate the newly flashed firmware, the user needs to
>> reboot his system.
>> 
>> The first patch introduces the mlxfw module, which implements common logic
>> needed for the firmware flash process on Mellanox products, such as the
>> MFA2 format parsing and the firmware flash state machine logic. As the
>> module implements common logic which will be needed by various different
>> Mellanox drivers, it defines a set of callbacks needed to interact with the
>> specific device.
>> 
>> Patches 1-5 implement the needed mlxfw callbacks in the mlxsw spectrum
>> driver.
>> 
>> Patches 6 and 7 add boot-time firmware upgrade on the mlxsw spectrum
>> driver.
>> 
>> Patch 8 adds a fix needed for new firmware versions.
>
>Series applied, although I hope you sort out the user interface
>soon otherwise most of this is completely dead unused code.

No dead code. The flashing is used internally from the driver on the
modprobe time. We are looking into the user interface at the moment.
Thanks.

>
>Thanks.
