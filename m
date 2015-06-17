From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] ipv4: include NLM_F_APPEND flag in append
 route notifications
Date: Wed, 17 Jun 2015 13:37:23 -0700
Message-ID: <5581DA83.9060504@cumulusnetworks.com>
References: <1434564421-32047-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bBAWVKV4vtv7kJFS+MxzWMTHjxPJJ=h-+7kj8WSrZjn3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33308 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753403AbbFQUhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 16:37:25 -0400
Received: by pdjn11 with SMTP id n11so48695057pdj.0
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 13:37:24 -0700 (PDT)
In-Reply-To: <CAE4R7bBAWVKV4vtv7kJFS+MxzWMTHjxPJJ=h-+7kj8WSrZjn3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/17/15, 11:30 AM, Scott Feldman wrote:
> On Wed, Jun 17, 2015 at 11:07 AM, Roopa Prabhu
> <roopa@cumulusnetworks.com> wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch adds NLM_F_APPEND flag to struct nlmsg_hdr->nlmsg_flags
>> in newroute notifications if the route add was an append.
>> (This is similar to how NLM_F_REPLACE is already part of new
>> route replace notifications today)
>>
>> This helps userspace determine if the route add operation was
>> an append.
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>> v2: flip if condition around append and change |= to =
>> (feedback from Alexander Duyck and Scott Feldman)
> Is this a bug fix for net, or a new feature for net-next?  Regardless,
>
> Acked-by: Scott Feldman <sfeldma@gmail.com>
I could not decide between net and net-next.
....but the patch applies cleanly against net if Dave decides to pick it 
up for net.
