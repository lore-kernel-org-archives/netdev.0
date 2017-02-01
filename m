From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 0/2] rx zero copy interface for af_packet
Date: Tue, 31 Jan 2017 21:09:07 -0800
Message-ID: <58916D73.7040303@gmail.com>
References: <20170127213132.14162.82951.stgit@john-Precision-Tower-5810>
 <4f68b864-8b9d-a57f-0843-30f613260b17@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: tndave <tushar.n.dave@oracle.com>, bjorn.topel@gmail.com,
        jasowang@redhat.com, ast@fb.com, alexander.duyck@gmail.com,
        brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35747 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751237AbdBAFJ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 00:09:26 -0500
Received: by mail-pf0-f195.google.com with SMTP id f144so30914882pfa.2
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 21:09:25 -0800 (PST)
In-Reply-To: <4f68b864-8b9d-a57f-0843-30f613260b17@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-31 11:39 AM, tndave wrote:
> 
> 
> On 01/27/2017 01:33 PM, John Fastabend wrote:
>> This is an experimental implementation of rx zero copy for af_packet.
>> Its a bit rough and likely has errors but the plan is to clean it up
>> over the next few months.
>>
>> And seeing I said I would post it in another thread a few days back
>> here it is.
> 
> This sounds good (believe me I have been thinking along the lines :)
> From driver Rx side, we always premap RX buffers so best to map them to
> shmem for PF_PACKET sockets.
> Also, I like the idea that user can put selected queue (may be queues in
> future?) to PF_PACKET mode keeping rest of the queues as it is.
> Zero copy and removing skb setup & processing overhead on RX certainly
> makes things faster and help latency. Zero copy is good on Tx however
> without skb should we figure out how to use segmentation and checksum offloading
> features of HW. Can this be considered in tpacket V4 hdr!
> 

Yes, I'll try to create another RFC in a week or two. Thanks.

> -Tushar
