From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Kernel panic in inet_twdr_do_twkill_work
Date: Tue, 02 Jun 2009 17:40:28 -0700
Message-ID: <m1r5y2jgjn.fsf@fess.ebiederm.org>
References: <m17i0ktr4p.fsf@fess.ebiederm.org> <4A0BCE0E.3000206@free.fr>
	<m1y6t0nlle.fsf@fess.ebiederm.org> <4A0BD750.4030605@free.fr>
	<m18wl0nj2b.fsf@fess.ebiederm.org> <4A194B09.7070900@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:44406 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbZFCAka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 20:40:30 -0400
In-Reply-To: <4A194B09.7070900@free.fr> (Daniel Lezcano's message of "Sun\, 24 May 2009 15\:26\:33 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano <daniel.lezcano@free.fr> writes:

> Eric W. Biederman wrote:
>> Daniel Lezcano <daniel.lezcano@free.fr> writes:
>>
>>   
>>> May be you can activate the NETNS_REFCNT_DEBUG in order to check if the timewait
>>> socket
>>> were destroyed at the namespace destruction ? Unfortunately it looks like the
>>> option is not in the Kconfig :(
>>>     
>>
>> Looks like a good starting place.
>>
>> I will enable that when I respin my internal kernel.
>>
>> I don't have a good reproducer at the moment....  So I was hoping we could
>> figure this out with code inspection.
>>   
> Hi Eric,
>
> did you succeeded to reproduce the bug with the test program I sent you ?

Weird.  I finally got around to running your little test app, and I don't trigger
it here.

At the same time I am starting to see what I think is this error more often.

Eric
