From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: echo > 0 .../disable_ipv6 broken in 2.6.37-rc4
Date: Sun, 05 Dec 2010 21:51:15 -0800
Message-ID: <m1fwubjvos.fsf@fess.ebiederm.org>
References: <m17hfnlpe1.fsf@fess.ebiederm.org>
	<AANLkTin4hO63J4thByJeG2SiGHn9ZqsbWKy1p_TEfeu_@mail.gmail.com>
	<m1zksjka4x.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Brian Haley <brian.haley@hp.com>,
	Mahesh Kelkar <maheshkelkar@gmail.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53447 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748Ab0LFFvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 00:51:20 -0500
In-Reply-To: <m1zksjka4x.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Sun, 05 Dec 2010 16:39:10 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ebiederm@xmission.com (Eric W. Biederman) writes:

> Lorenzo Colitti <lorenzo@google.com> writes:
>
>> On Sun, Dec 5, 2010 at 4:24 PM, Eric W. Biederman <ebiederm@xmission.com> wrote:
>>> In 2.6.37-rc4 ipv6 can be disabled not enabled.
>>> The last kernel I have tested and know this works on is 2.6.33.
>>
>> I'm pretty sure I could successfully re-enable IPv6 on non-loopback
>> interfaces (wlan0, eth0) on net-2.6 pulled a little after 2.6.37-rc1.
>> I didn't try lo though. Does re-enabling IPv6 on a "real" interface
>> still work?
>
> Interesting that case seems to work.


It isn't the address state remove on ifdown either.

Lorenzo reverting your patch 2de795707294972f6c34bae9de713e502c431296
has no affect so you are cleared.

Darn those were the easy possibilities, now I have to stop and actually
pay attention to what the code is doing to debug this.

Eric
