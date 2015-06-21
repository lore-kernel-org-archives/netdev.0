From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv4: include NLM_F_APPEND flag in append
 route notifications
Date: Sun, 21 Jun 2015 10:23:57 -0700 (PDT)
Message-ID: <20150621.102357.102968042925261063.davem@davemloft.net>
References: <1434564421-32047-1-git-send-email-roopa@cumulusnetworks.com>
	<CAE4R7bBAWVKV4vtv7kJFS+MxzWMTHjxPJJ=h-+7kj8WSrZjn3Q@mail.gmail.com>
	<5581DA83.9060504@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org,
	alexander.duyck@gmail.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46814 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344AbbFURMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 13:12:10 -0400
In-Reply-To: <5581DA83.9060504@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa <roopa@cumulusnetworks.com>
Date: Wed, 17 Jun 2015 13:37:23 -0700

> On 6/17/15, 11:30 AM, Scott Feldman wrote:
>> On Wed, Jun 17, 2015 at 11:07 AM, Roopa Prabhu
>> <roopa@cumulusnetworks.com> wrote:
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> This patch adds NLM_F_APPEND flag to struct nlmsg_hdr->nlmsg_flags
>>> in newroute notifications if the route add was an append.
>>> (This is similar to how NLM_F_REPLACE is already part of new
>>> route replace notifications today)
>>>
>>> This helps userspace determine if the route add operation was
>>> an append.
>>>
>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>> ---
>>> v2: flip if condition around append and change |= to =
>>> (feedback from Alexander Duyck and Scott Feldman)
>> Is this a bug fix for net, or a new feature for net-next?  Regardless,
>>
>> Acked-by: Scott Feldman <sfeldma@gmail.com>
> I could not decide between net and net-next.
> ....but the patch applies cleanly against net if Dave decides to pick
> it up for net.

It's been like this for so long that it's more like a new feature.

Therefore, applied to net-next, thanks.
