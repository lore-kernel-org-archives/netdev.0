From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: add regs attribute to phy device for user diagnose
Date: Sat, 14 Jan 2017 10:35:44 -0800
Message-ID: <da255b0c-dba6-ef35-d436-3110d8492f95@gmail.com>
References: <1484361992-30591-1-git-send-email-cugyly@163.com>
 <20170114162453.GB1072@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: Andrew Lunn <andrew@lunn.ch>, yuan linyu <cugyly@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33106 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751603AbdANSfo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 13:35:44 -0500
Received: by mail-qk0-f193.google.com with SMTP id 11so11406312qkl.0
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2017 10:35:44 -0800 (PST)
In-Reply-To: <20170114162453.GB1072@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/2017 08:24 AM, Andrew Lunn wrote:
> On Sat, Jan 14, 2017 at 10:46:31AM +0800, yuan linyu wrote:
>> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
>>
>> if phy device have register(s) configuration problem,
>> user can use this attribute to diagnose.
>> this feature need phy driver maintainer implement.
> 
> what is wrong with mii-tool -vv ?

Agreed, and without an actual user of this API (ethtool?), nor a PHY
driver implementing it, we cannot quite see how you want to make use of
this.

Thank you
-- 
Florian
