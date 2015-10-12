From: wangyufen <wangyufen@huawei.com>
Subject: Issue with /proc/sys/net/ipv4/tcp_mem
Date: Mon, 12 Oct 2015 17:38:32 +0800
Message-ID: <561B7F98.1040809@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:62658 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173AbbJLJkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 05:40:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I tried on linux-4.1:
    linux:~# cat /proc/sys/net/ipv4/tcp_mem 
    8388608	12582912	16777216
    linux:~# echo 1234 >/proc/sys/net/ipv4/tcp_mem 
    -bash: echo: write error: Invalid argument
    linux:~# cat /proc/sys/net/ipv4/tcp_mem 
    1234	12582912	16777216

the echo operation got error, but value already written to tcp_mem.

I checked, patch f594d63199688ad568fb caused the issue.


thanks,
Wang
