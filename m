From: Nick Carter <ncarter100@gmail.com>
Subject: Re: [PATCH] bridge: Forward EAPOL when STP off
Date: Thu, 23 Jun 2011 22:30:03 +0100
Message-ID: <BANLkTi=kUSr9yeOkyjn5oYcn6gtiFTKf_w@mail.gmail.com>
References: <BANLkTimdK-5tsWcTFbe_-82fHxr4TN4F_g@mail.gmail.com>
	<20110604224209.5c784729@s6510.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, benjamin.poirier@gmail.com,
	davem@davemloft.net, shemminger@linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:49469 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784Ab1FWVaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 17:30:04 -0400
Received: by pwj7 with SMTP id 7so1457832pwj.19
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2011 14:30:03 -0700 (PDT)
In-Reply-To: <20110604224209.5c784729@s6510.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen,

It doesn't look like ebtables can do this
http://www.spinics.net/lists/netfilter/msg51200.html

I've written some new diffs that I will send out to netdev.

Thanks,
Nick

On 4 June 2011 14:42, Stephen Hemminger <shemminger@vyatta.com> wrote:
> On Thu, 2 Jun 2011 16:59:13 +0100
> Nick Carter <ncarter100@gmail.com> wrote:
>
>> Signed-off-by: Nick Carter <ncarter100@gmail.com>
>>
>> If STP is disabled then forward frames destined to the 802.1X PAE group
>> address (01-80-C2-00-00-03)
>>
>> This change is required to support virtual machines running an 802.1X
>> supplicant and bridged to an ethernet interface.
>>
>> This change has been tested and works fine with a range of supplicants.
>
> No. This is getting messy and starts down the path of the recent
> 802.3ad change which just got reverted. A better solution is needed
> than individual hacky standards breaking. If you really need to do
> this, use the "duct tape" of networking ebtables.
>
> See also:
> https://lists.linux-foundation.org/pipermail/bridge/2007-November/005638.html
>
