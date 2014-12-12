From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: errors in alignment changes..
Date: Fri, 12 Dec 2014 15:00:16 +0300
Message-ID: <548AD8D0.4040207@cogentembedded.com>
References: <20141210.155203.1136471667049608187.davem@davemloft.net> <5488C447.5080906@cogentembedded.com> <20141210.204215.46146677361631214.davem@davemloft.net> <20141212043010.GC17790@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mitsuhiro.kimura.kc@renesas.com, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:40360 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966334AbaLLMAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 07:00:20 -0500
Received: by mail-la0-f49.google.com with SMTP id hs14so5986198lab.36
        for <netdev@vger.kernel.org>; Fri, 12 Dec 2014 04:00:18 -0800 (PST)
In-Reply-To: <20141212043010.GC17790@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/12/2014 7:30 AM, Simon Horman wrote:

>> From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>> Date: Thu, 11 Dec 2014 01:08:07 +0300

>>>     I guess we can just do:

>>> 		rxdesc->addr = dma_map_single(...);

>> Best not to leave a potentially invalid DMA address in a
>> receive descriptor the chip can potentially fetch and
>> look at.

>> That's why I said to put it into a local variable and
>> check for errors first.

> Hi Dave,

> this patch ending up in net is partially my fault.

> Sergei, do you have time to address David's concerns in relation to this
> patch?

    No, I probably don't.

> If not I would like to suggest reverting it for now.

    Why? The patch does what it was intended for. Getting rid of 
virt_to_phys() calls is a separate issue, IMO.

WBR, Sergei
