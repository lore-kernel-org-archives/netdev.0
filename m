From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net 2/3] net: sctp: fix panic on duplicate ASCONF chunks
Date: Sun, 12 Oct 2014 03:15:43 -0400
Message-ID: <CAGCdqXH1rcrqtqC-jwjpnimK+N=KJ_O7SvSK2xngX_8S0JodPw@mail.gmail.com>
References: <1412888133-833-1-git-send-email-dborkman@redhat.com>
	<1412888133-833-3-git-send-email-dborkman@redhat.com>
	<20141010153954.GE19499@hmsreliant.think-freely.org>
	<54385777.7090907@redhat.com>
	<20141012014233.GA16360@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>,
	David Miller <davem@davemloft.net>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:63369 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbaJLHPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2014 03:15:45 -0400
In-Reply-To: <20141012014233.GA16360@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I prefer we stay away from WARN-ONs, but pr_debug might be useful.

-vlad

On Sat, Oct 11, 2014 at 9:42 PM, Neil Horman <nhorman@tuxdriver.com> wrote:
> On Sat, Oct 11, 2014 at 12:02:31AM +0200, Daniel Borkmann wrote:
>> On 10/10/2014 05:39 PM, Neil Horman wrote:
>> ...
>> >Is it worth adding a WARN_ON, to indicate that two ASCONF chunks have been
>> >received with duplicate serials?
>>
>> Don't think so, as this would be triggerable from outside.
>>
> WARN_ON_ONCE then, per serial number?
> Neil
>
>> Thanks,
>> Daniel
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
