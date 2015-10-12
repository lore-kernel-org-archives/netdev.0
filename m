From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Issue with /proc/sys/net/ipv4/tcp_mem
Date: Mon, 12 Oct 2015 10:24:14 -0500
Message-ID: <87y4f8qfdt.fsf@x220.int.ebiederm.org>
References: <561B7F98.1040809@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: wangyufen <wangyufen@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:53612 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbbJLPcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 11:32:20 -0400
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

Use the cgroup interface if you want per cgroup control.

Eric
