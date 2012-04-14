From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/2] net: In unregister_netdevice_notifier unregister the netdevices.
Date: Fri, 13 Apr 2012 17:03:00 -0700
Message-ID: <m18vhz6uyz.fsf@fess.ebiederm.org>
References: <CA+1xoqdi4QOhRJvBA64pxiN3EphhThjPkf4eLRkYM8jxcJjh=w@mail.gmail.com>
	<m1mx6otk85.fsf@fess.ebiederm.org>
	<m1aa2otjf4.fsf_-_@fess.ebiederm.org>
	<20120413.110505.1391379079973352104.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, ericvh@gmail.com, davej@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	levinsasha928@gmail.com, remi.denis-courmont@nokia.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:34892 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757263Ab2DMX7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 19:59:08 -0400
In-Reply-To: <20120413.110505.1391379079973352104.davem@davemloft.net> (David
	Miller's message of "Fri, 13 Apr 2012 11:05:05 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Fri, 06 Apr 2012 18:33:35 -0700
>
>>>From a51fda849355b2ffb27cdb5d66fa1a96e7f47335 Mon Sep 17 00:00:00 2001
>> From: Eric W. Biederman <ebiederm@xmission.com>
>> Date: Sun, 25 Dec 2011 19:39:52 -0800
>> Subject: 
>
> Yikes, I had to edit this turd out :-)  Otherwise with this empty
> Subject, GIT uses the first line of your commit log body as the
> first line.

Ugh.  I usually do.  I think I was tired that day.

>> We already synthesize events in register_netdevice_notifier and synthesizing
>> events in unregister_netdevice_notifier allows to us remove the need for
>> special case cleanup code.
>> 
>> This change should be safe as it adds no new cases for existing callers
>> of unregiser_netdevice_notifier to handle.
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>
> Applied.

Thanks,

Eric
