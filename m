From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [PATCH net-next] filter: fix va_list build error
Date: Wed, 1 May 2013 18:29:40 -0400
Message-ID: <CAKU6vyaEtNC5ZNvF7_vx8gD+rMh1Jo6Wb_=BarLeG9h_VqkYDw@mail.gmail.com>
References: <1367439848-10854-1-git-send-email-xi.wang@gmail.com> <51818350.6040600@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Joe Perches <joe@perches.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:65305 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757608Ab3EAWaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 18:30:21 -0400
Received: by mail-oa0-f49.google.com with SMTP id j1so1817209oag.22
        for <netdev@vger.kernel.org>; Wed, 01 May 2013 15:30:20 -0700 (PDT)
In-Reply-To: <51818350.6040600@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 1, 2013 at 5:04 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> That's a bit weird. Xi, maybe in a follow-up some time later, could
> you move the GCC-internal stdarg.h rather into linux/printk.h, since
> that's where the problem is coming from? Imho, it might be better off
> there, no?

There was some discussion a while ago on whether to make printk.h self
contained or to disallow including it directly.  Joe Perches [CCed]
had patches for that.

https://lkml.org/lkml/2011/5/25/263

- xi
