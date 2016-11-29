From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2] libnetlink: reduce size of message sent to kernel
Date: Tue, 29 Nov 2016 13:07:44 -0800
Message-ID: <20161129130744.1bd8761d@samsung9>
References: <1479570613-3104-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34981 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756512AbcK2VHr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 16:07:47 -0500
Received: by mail-pf0-f181.google.com with SMTP id i88so33854764pfk.2
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 13:07:47 -0800 (PST)
In-Reply-To: <1479570613-3104-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 19 Nov 2016 23:50:13 +0800
Zhang Shengju <zhangshengju@cmss.chinamobile.com> wrote:

> This patch reduce the size of message sent to kernel space. Before this
> patch, for command: 'ip link show', we will sent 1056 bytes. With this
> patch, we only need to send 40 bytes.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied, and queued for next push.
Added a Fixes tag since this was introduced by changes to do selective query.
