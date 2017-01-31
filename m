From: tndave <tushar.n.dave@oracle.com>
Subject: Re: [RFC PATCH 0/2] rx zero copy interface for af_packet
Date: Tue, 31 Jan 2017 11:39:16 -0800
Message-ID: <4f68b864-8b9d-a57f-0843-30f613260b17@oracle.com>
References: <20170127213132.14162.82951.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>, bjorn.topel@gmail.com,
        jasowang@redhat.com, ast@fb.com, alexander.duyck@gmail.com,
        brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26035 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751873AbdAaTlB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 14:41:01 -0500
In-Reply-To: <20170127213132.14162.82951.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/27/2017 01:33 PM, John Fastabend wrote:
> This is an experimental implementation of rx zero copy for af_packet.
> Its a bit rough and likely has errors but the plan is to clean it up
> over the next few months.
>
> And seeing I said I would post it in another thread a few days back
> here it is.

This sounds good (believe me I have been thinking along the lines :)
 From driver Rx side, we always premap RX buffers so best to map them to
shmem for PF_PACKET sockets.
Also, I like the idea that user can put selected queue (may be queues in
future?) to PF_PACKET mode keeping rest of the queues as it is.
Zero copy and removing skb setup & processing overhead on RX certainly
makes things faster and help latency. Zero copy is good on Tx however
without skb should we figure out how to use segmentation and checksum 
offloading features of HW. Can this be considered in tpacket V4 hdr!

-Tushar
