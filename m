From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH net-next 1/2] net: use dev->name in netdev_pr* when it's available
Date: Thu, 17 Jul 2014 15:48:45 +0200
Message-ID: <CAG-2HqXhU5RHkMOyj9H2CboYJ1LNFnXzXC_QaAML8P1tihmahg@mail.gmail.com>
References: <1405596491-5881-1-git-send-email-vfalico@gmail.com> <1405596491-5881-2-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:52582 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932901AbaGQNtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 09:49:06 -0400
Received: by mail-yk0-f181.google.com with SMTP id q200so1192788ykb.40
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 06:49:06 -0700 (PDT)
In-Reply-To: <1405596491-5881-2-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2014 at 1:28 PM, Veaceslav Falico <vfalico@gmail.com> wrote:
> e() returns dev->name only when the net_device is in
> NETREG_REGISTERED state.
>
> However, dev->name is always populated on creation, so we can easily use
> it. The only caveat is that the device still has a name of type "eth%d", in
> which case we cannot use this name as it'll change in the nearest future,
> thus return "unnamed net_device".

There are also cases when the name is set to emptystring before being
populated with the real name later on. You may want to check for that
too.

Cheers,

Tom
