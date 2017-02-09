From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v2 1/8] xdp: Infrastructure to generalize XDP
Date: Thu, 09 Feb 2017 17:17:06 -0500 (EST)
Message-ID: <20170209.171706.1575416693138040726.davem@davemloft.net>
References: <20170208234127.3041579-1-tom@herbertland.com>
        <20170208234127.3041579-2-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51648 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751983AbdBIWSQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 17:18:16 -0500
In-Reply-To: <20170208234127.3041579-2-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 8 Feb 2017 15:41:20 -0800

> These hooks are also generic to allow for XDP/BPF programs as well
> as non-BPF code (e.g. kernel code can be written in a module).

I don't think we should even remotely consider surrendering the XDP
hook to module code.

We restrict it to eBPF for a reason, because that framework is
restricted in what it can do, what it can access, and how it can do
so.

Tom if you're going to do a cleanup that makes it so that drivers
need less code to support XDP, that is awesome but please do only
that.

Don't combine it with more controversial changes.

Thank you.
