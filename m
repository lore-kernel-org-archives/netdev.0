From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: cpsw forwards broadcasts on all interfaces in dual_emac mode
Date: Tue, 3 Jun 2014 08:16:17 +0200
Message-ID: <CAGm1_kuw07q725bPZH8CAfQBkVDj06ZF9G2fQq0F5CNx4+UjGQ@mail.gmail.com>
References: <538C2878.903@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mugunthan V N <mugunthanvnm@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jan Altenberg <jan@linutronix.de>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:56739 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932076AbaFCGQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 02:16:38 -0400
Received: by mail-pa0-f52.google.com with SMTP id bj1so4742193pad.11
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 23:16:37 -0700 (PDT)
In-Reply-To: <538C2878.903@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sebastian,

On Mon, Jun 2, 2014 at 9:32 AM, Sebastian Andrzej Siewior
<bigeasy@linutronix.de> wrote:
> Hi Mugunthan,
>
> I've been playing with the dual_emac mode and I noticed that if eth0
> receives broadcasts packets then it will forward them to eth1. I assume
> that it either has one ALE rule too much or is missing one. Do you have
> any idea what it might be?

I've also encountered this problem. See this thread:
http://e2e.ti.com/support/arm/sitara_arm/f/791/t/338292.aspx?pi301021=1

Still had no time to dig the driver and TRM. Hope Mugunthan can help
to sort the things out.

Yegor
