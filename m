From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH] TCPCT+1: initial SYN exchange with SYNACK data
Date: Mon, 05 Oct 2009 03:45:51 -0400
Message-ID: <4AC9A42F.7010302@gmail.com>
References: <4AC79905.1030904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.211.173]:42589 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758258AbZJEHqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 03:46:30 -0400
Received: by ywh3 with SMTP id 3so2710961ywh.22
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2009 00:45:53 -0700 (PDT)
In-Reply-To: <4AC79905.1030904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As I'm new to Linux kernel development, this was based entirely on code
previously reviewed (by Miller), as that seemed a good path for me to learn
proper coding and style.

Now that I'm trying to grok Linux locking functions for the next patch, I've
noticed that setsockopt code uses lock_sock(), but getsockopt doesn't.  In a
preemptive kernel, or with SMP, isn't there a possibility that these socket
values could be modified or destroyed at the same time?

I'm especially concerned here, as there are kref blocks, and they could be
left pointing into the weeds?
