From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next][PATCH v2 01/13] RDS: Drop stale iWARP RDMA transport
Date: Sun, 28 Feb 2016 21:51:14 +0200
Message-ID: <CAJ3xEMioB61bN9RAcAx9BecYGdWPs9QZNYUrm+r8=rt0WFMzKQ@mail.gmail.com>
References: <1456625990-4739-1-git-send-email-santosh.shilimkar@oracle.com>
	<1456625990-4739-2-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35182 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754612AbcB1TvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 14:51:16 -0500
Received: by mail-io0-f193.google.com with SMTP id z135so12372051iof.2
        for <netdev@vger.kernel.org>; Sun, 28 Feb 2016 11:51:15 -0800 (PST)
In-Reply-To: <1456625990-4739-2-git-send-email-santosh.shilimkar@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 28, 2016 at 4:19 AM, Santosh Shilimkar
<santosh.shilimkar@oracle.com> wrote:
> RDS iWarp support code has become stale and non testable. As
> indicated earlier, am dropping the support for it.
>
> If new iWarp user(s) shows up in future, we can adapat the RDS IB
> transprt for the special RDMA READ sink case. iWarp needs an MR
> for the RDMA READ sink.
>
> Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>

Hi, just wondered if there's any special reason that all this series
carries double S.O.B signature line with your name appearing twice on
two different email addresses?
