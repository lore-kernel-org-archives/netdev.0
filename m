From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] nfc: use GFP_USER for user-controlled kmalloc
Date: Fri, 29 Jan 2016 11:46:04 -0800
Message-ID: <1454096764.7627.66.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454095465-16685-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com,
	linux-wireless@vger.kernel.org, julian.calaby@gmail.com,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35596 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753757AbcA2TqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 14:46:05 -0500
In-Reply-To: <1454095465-16685-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-29 at 11:24 -0800, Cong Wang wrote:
> These two functions are called in sendmsg path, and the
> 'len' is passed from user-space, so we should not allow
> malicious users to OOM kernel on purpose.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>
> Cc: Aloisio Almeida Jr <aloisio.almeida@openbossa.org>
> Cc: Samuel Ortiz <sameo@linux.intel.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---

Note that the issue is not OOM the kernel (as the allocation is
attempted even after your patch), but having a way to
spill stack traces in the syslog.

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks!
