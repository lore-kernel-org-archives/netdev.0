From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net: flush the softnet backlog in process context
Date: Thu, 28 Jul 2016 07:45:39 +0200
Message-ID: <1469684739.9389.6.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1e1b4ce29a5c254ab3ca605003bb622afb204c87.1469615619.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37653 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752636AbcG1FqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 01:46:03 -0400
Received: by mail-wm0-f45.google.com with SMTP id i5so90712310wmg.0
        for <netdev@vger.kernel.org>; Wed, 27 Jul 2016 22:46:03 -0700 (PDT)
In-Reply-To: <1e1b4ce29a5c254ab3ca605003bb622afb204c87.1469615619.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2016-07-27 at 12:37 +0200, Paolo Abeni wrote:
> Currently in process_backlog(), the process_queue dequeuing is
> performed with local IRQ disabled, to protect against
> flush_backlog(), which runs in hard IRQ context.

Thanks guys, patch looks fine to me.
