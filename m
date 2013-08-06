From: Jason Wang <jasowang@redhat.com>
Subject: Re: macvtap MAX_SKB_FRAGS fix...
Date: Tue, 06 Aug 2013 17:34:46 +0800
Message-ID: <5200C336.20807@redhat.com>
References: <20130805.205104.295403081094571911.davem@davemloft.net> <5200B626.9030006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61253 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755275Ab3HFJf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 05:35:27 -0400
In-Reply-To: <5200B626.9030006@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2013 04:39 PM, Jason Wang wrote:
> On 08/06/2013 11:51 AM, David Miller wrote:
>> Jason, I want to get that into v3.4.x -stable but it needs a backport
>> and I'd rather someone like you who knows the code does it rather
>> than I.
>>
>> The issue seems that be that the arguments to uarg->callback() were
>> different back then.
>>
>> Thanks.
> Sure.
>
> For 3.4.x we need to pick c70aa540c7a9f67add11ad3161096fb95233aa2e
> (vhost: zerocopy: poll vq in zerocopy callback) first to let the
> backport work. The reason of different arguments is because 3.4.x does
> not track DMA failure. So we can just do uarg->callback(uarg);
>
> Please see the attached patches.

Looks like a git send-email is better, will post them.
>
> Thanks
>
