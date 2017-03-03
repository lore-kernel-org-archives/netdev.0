From: Brad Campbell <lists2009@fnarfbargle.com>
Subject: Re: [Patch net] bonding: use ETH_MAX_MTU as max mtu
Date: Fri, 3 Mar 2017 09:17:22 +0800
Message-ID: <31ca1489-ee28-0db9-bc45-8e9c71ac4b7e@fnarfbargle.com>
References: <1488486276-24552-1-git-send-email-xiyou.wangcong@gmail.com>
 <20170302.144358.779284930067468307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daznis@gmail.com, jarod@redhat.com
To: David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns3.fnarfbargle.com ([43.245.164.105]:58727 "EHLO
        ns3.fnarfbargle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751610AbdCCBRg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 20:17:36 -0500
In-Reply-To: <20170302.144358.779284930067468307.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/17 06:43, David Miller wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Thu,  2 Mar 2017 12:24:36 -0800
>
>> This restores the ability of setting bond device's mtu to 9000.
>>
>> Fixes: 91572088e3fd ("net: use core MTU range checking in core net infra")
>> Reported-by: daznis@gmail.com
>> Reported-by: Brad Campbell <lists2009@fnarfbargle.com>
>> Cc: Jarod Wilson <jarod@redhat.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
> Applied and queued up for -stable, thanks.
>

Thanks very much for this. I've tested it against 4.10.1 and it does the 
job nicely.

Regards,
Brad
