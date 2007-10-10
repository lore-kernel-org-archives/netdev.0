From: "Denis V. Lunev" <den@sw.ru>
Subject: Re: [PATCH] ipv4: kernel panic when only one unsecured port available
Date: Wed, 10 Oct 2007 12:27:29 +0400
Message-ID: <470C8CF1.4050706@sw.ru>
References: <m3bqb89yjw.fsf@bandura.englab.brq.redhat.com>	<470C773C.2050700@sw.ru> <m3hckzl6ui.fsf@bandura.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Anton Arapov <aarapov@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:52867 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752816AbXJJIZs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 04:25:48 -0400
In-Reply-To: <m3hckzl6ui.fsf@bandura.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anton Arapov wrote:
> Hi,
> 
> "Denis V. Lunev" <den@sw.ru> writes:
>> This code is broken from the very beginning.
>>
>> iris den # cat /proc/sys/net/ipv4/ip_local_port_range
>> 32768   61000
>> iris den # echo 32768 32 >/proc/sys/net/ipv4/ip_local_port_range
>> iris den # cat /proc/sys/net/ipv4/ip_local_port_range
>> 32768   32
>> iris den # echo 32768 61000 >/proc/sys/net/ipv4/ip_local_port_range
> 
>   If you're talking about checks in sysctl, I believe it should be
> another patch for sysctl only, and I'm going to push it via -mm tree.
> 
>   the devision by zero exists in inet_connection_socket.c, and must be
> fixed for sure because the situation with the same min and max port
> numbers in sysctl are possible and not prohibited.
> 
> Cheers!

your patch change nothing :( unfortunately. If I set '32768 32767' it
will oops again.

Regards,
	Den
