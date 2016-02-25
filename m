From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 0/5] net_sched: Add support for IFE action
Date: Thu, 25 Feb 2016 07:23:30 -0500
Message-ID: <56CEF242.5090908@mojatatu.com>
References: <1456147304-13355-1-git-send-email-jhs@emojatatu.com>
 <56CB3B90.8030206@iogearbox.net> <56CC4BEA.70108@mojatatu.com>
 <56CC5CB6.1030807@iogearbox.net> <56CC6C75.1000903@mojatatu.com>
 <56CC7C20.3090302@iogearbox.net> <56CDA6E8.7010604@mojatatu.com>
 <56CDECE5.5040604@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:35978 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760328AbcBYMXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 07:23:32 -0500
Received: by mail-ig0-f195.google.com with SMTP id xg9so871071igb.3
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 04:23:32 -0800 (PST)
In-Reply-To: <56CDECE5.5040604@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-24 12:48 PM, Daniel Borkmann wrote:
> On 02/24/2016 01:49 PM, Jamal Hadi Salim wrote:

>> Drivers do set the hash. My use case is slightly different.
>> I have a NIC which has an embedded cavium processor. This thing
>> strips off the TLV and uses the hash to select the host MSI.
>> Only thing we dont use at the moment is queue_mapping.
>
> Ok, but the example says ingress qdisc. ;) I presume the driver for the
> NIC and the offloading parts are non-public? :/

Well, it is not exactly mellanox or intel - but I am sure someone would
be willing to sell that NIC.

> So, without them, placing
> this on ingress qdisc doesn't seem much useful wrt the skb hash example,
> and most people only have the software part (for ingress I mean) available.

Do you want me to take skbbhash out? I just want to get this set in then
worry about adding and modifying.

cheers,
jamal
