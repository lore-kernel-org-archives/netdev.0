From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] of_mdio: use of_property_read_u32_array()
Date: Mon, 7 Aug 2017 19:18:09 +0300
Message-ID: <080ebcb6-b5aa-63db-176b-83477c2540e5@cogentembedded.com>
References: <20170804214354.351406407@cogentembedded.com>
 <CAL_JsqKDXAbAVpgMSU39+9mF7MZWQotLUNkjePy9eUsnBs99Vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Frank Rowand <frowand.list@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Rob Herring <robh+dt@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:33717 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751426AbdHGQSN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 12:18:13 -0400
Received: by mail-lf0-f48.google.com with SMTP id d17so4130254lfe.0
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 09:18:13 -0700 (PDT)
In-Reply-To: <CAL_JsqKDXAbAVpgMSU39+9mF7MZWQotLUNkjePy9eUsnBs99Vw@mail.gmail.com>
Content-Language: en-MW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 08/07/2017 05:18 PM, Rob Herring wrote:

>> The "fixed-link" prop support predated of_property_read_u32_array(), so
>> basically had to open-code it. Using the modern API saves 24 bytes of the
>> object code (ARM gcc 4.8.5); the only behavior change would be that the
>> prop length check is now less strict (however the strict pre-check done
>> in of_phy_is_fixed_link() is left intact anyway)...
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>
>> ---
>> The patch is against the 'dt/next' branch of Rob Herring's 'linux-git' repo
>> plus the previously posted patch killing the useless local variable in
>> of_phy_register_fixed_link().
> 
> It shouldn't depend on anything in my tree and David normally takes
> of_mdio.c changes.

    MAINTAINERS still only point at the DT repo, perhaps it should be updated?

> Reviewed-by: Rob Herring <robh@kernel.org>

    Thank you.

>>   drivers/of/of_mdio.c |   16 ++++++++--------
>>   1 file changed, 8 insertions(+), 8 deletions(-)

MBR, Sergei
