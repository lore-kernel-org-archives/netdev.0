From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] bonding: clear header_ops when last slave detached (v2)
Date: Wed, 19 Nov 2014 14:26:02 -0800
Message-ID: <CAHA+R7OyA_V149bpE8qUgG9epU-5UG8cf=zOgh5ZXVB3ZFZHUw@mail.gmail.com>
References: <1416374292-10993-1-git-send-email-wen.gang.wang@oracle.com>
	<1416375565.14060.43.camel@edumazet-glaptop2.roam.corp.google.com>
	<546C4022.5010509@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Wengang <wen.gang.wang@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:57513 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757537AbaKSW0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 17:26:03 -0500
Received: by mail-qc0-f177.google.com with SMTP id x3so1243797qcv.36
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 14:26:02 -0800 (PST)
In-Reply-To: <546C4022.5010509@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2014 at 11:00 PM, Wengang <wen.gang.wang@oracle.com> wrote:
>
> Yes, that's true. So the simplest way is move ipoib_header_ops to vmlinux.
>

That is not an option. Perhaps you need RCU to protect the dev->header_ops
pointer.
