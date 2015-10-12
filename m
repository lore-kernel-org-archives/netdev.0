From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Issue with /proc/sys/net/ipv4/tcp_mem
Date: Mon, 12 Oct 2015 11:37:02 -0500
Message-ID: <87io6coxg1.fsf@x220.int.ebiederm.org>
References: <561B7F98.1040809@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: wangyufen <wangyufen@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:40167 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbbJLQol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 12:44:41 -0400
In-Reply-To: <561B7F98.1040809@huawei.com> (wangyufen@huawei.com's message of
	"Mon, 12 Oct 2015 17:38:32 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

wangyufen <wangyufen@huawei.com> writes:

> Hi,
>
> I tried on linux-4.1:
>     linux:~# cat /proc/sys/net/ipv4/tcp_mem 
>     8388608	12582912	16777216
>     linux:~# echo 1234 >/proc/sys/net/ipv4/tcp_mem 
>     -bash: echo: write error: Invalid argument
>     linux:~# cat /proc/sys/net/ipv4/tcp_mem 
>     1234	12582912	16777216
>
> the echo operation got error, but value already written to tcp_mem.
>
> I checked, patch f594d63199688ad568fb caused the issue.


If your problem is that you can not write a single value and instead
have to write all three values I don't know what to tell you.  I don't
see how that could have ever worked.

Certainly the commit you pointed at did not change that behavior.

Eric
