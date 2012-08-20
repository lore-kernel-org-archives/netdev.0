From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 1/2] iproute: Add magic cookie to route dump file
Date: Mon, 20 Aug 2012 12:05:38 +0400
Message-ID: <5031EFD2.5000802@parallels.com>
References: <50121F4D.8090606@parallels.com> <20120817134943.6f26a75e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:6067 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755646Ab2HTIFo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 04:05:44 -0400
In-Reply-To: <20120817134943.6f26a75e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/18/2012 12:49 AM, Stephen Hemminger wrote:
> On Fri, 27 Jul 2012 08:55:41 +0400
> Pavel Emelyanov <xemul@parallels.com> wrote:
> 
>> In order to somehow verify that a blob contains route dump a
>> 4-bytes magic is put at the head of the data and is checked
>> on restore.
>>
>> Magic digits are taken from Portland (OR) coordinates :) Is
>> there any more reliable way of generating such?
>>
>> Signed-of-by: Pavel Emelyanov <xemul@parallels.com>
> 
> I am planning on putting this in because there were no objections.
> Any followup updates?

Yes, I've recently found that errno propagation from rtnl_talk up to
addrs/routes restore doesn't work on some libc-s. I will post a fixing
patch soon.

Thanks,
Pavel
