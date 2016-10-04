From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH v2 net-next 5/7] xen-netback: process guest rx
 packets in batches
Date: Tue, 4 Oct 2016 15:51:04 +0100
Message-ID: <f26482a6-5f6f-126e-ae72-6dfcbbafd58c@citrix.com>
References: <1475573358-32414-1-git-send-email-paul.durrant@citrix.com>
 <1475573358-32414-6-git-send-email-paul.durrant@citrix.com>
 <20161004124744.GC30836@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Wei Liu <wei.liu2@citrix.com>,
        David Vrabel <david.vrabel@citrix.com>,
        <xen-devel@lists.xenproject.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:16053 "EHLO SMTP.CITRIX.COM"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751527AbcJDOvk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 10:51:40 -0400
In-Reply-To: <20161004124744.GC30836@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/16 13:47, Konrad Rzeszutek Wilk wrote:
> On Tue, Oct 04, 2016 at 10:29:16AM +0100, Paul Durrant wrote:
>> From: David Vrabel <david.vrabel@citrix.com>
>>
>> Instead of only placing one skb on the guest rx ring at a time, process
>> a batch of up-to 64.  This improves performance by ~10% in some tests.
> 
> And does it regress latency workloads?

No. Because the loop outside of these batches is only checking for a
fatal error condition or a disconnection.

> What are those 'some tests' you speak off?

I think it was aggregate intrahost, but I don't remember exactly.

David
