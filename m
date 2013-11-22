From: Tom Herbert <therbert@google.com>
Subject: Re: Get rxhash fixes and RFS support in tun
Date: Fri, 22 Nov 2013 12:09:18 -0800
Message-ID: <CA+mtBx_GkvRg++JCg-wjmuYvC3wWizFkOaTuKqni1i-E6ata8g@mail.gmail.com>
References: <alpine.DEB.2.02.1311201220510.19725@tomh.mtv.corp.google.com>
	<528D940A.5010803@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jerry Chu <hkchu@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:44416 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755898Ab3KVUJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 15:09:21 -0500
Received: by mail-ie0-f176.google.com with SMTP id at1so2832489iec.7
        for <netdev@vger.kernel.org>; Fri, 22 Nov 2013 12:09:20 -0800 (PST)
In-Reply-To: <528D940A.5010803@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 20, 2013 at 9:03 PM, Jason Wang <jasowang@redhat.com> wrote:
> On 11/21/2013 04:25 AM, Tom Herbert wrote:
>> This patch series fixes some subtle bugs in tun use of skb->rxhash, all
>> rxhash hash not be cleared appropraitely, and adds support for tun flows
>> to work with RFS.
>>
>>
>> Testing, in particular with tun, hasn't been completed yet.
>
> Interesting work, did you plan to test this with a kvm guest or even a
> multi-queue guest?
>
Yes, I think that is the direction.  Once we clean up the hashing in
the stack, next thing will be to extend RPS/RFS and computed hashes
functionality all the way into the guest.  I'm not sure yet if the
flow director like mechanism (like in tun) is sufficient, or if we
want to expose aRFS to the guest driver.  As I mentioned, first we
need to test RFS integration in tun to see the effect.

> Thanks
