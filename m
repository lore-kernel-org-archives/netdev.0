From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip monitor: Enable prefix labels when monitoring more
 than 1 object
Date: Thu, 15 Aug 2013 23:40:47 -0700
Message-ID: <20130815234047.0018f3dd@nehalam.linuxnetplumber.net>
References: <20130815070527.1df23bea@martins.ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Martin Schwenke <martin@meltin.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:60811 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845Ab3HPGkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 02:40:51 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so1834354pdj.40
        for <netdev@vger.kernel.org>; Thu, 15 Aug 2013 23:40:50 -0700 (PDT)
In-Reply-To: <20130815070527.1df23bea@martins.ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Aug 2013 07:05:27 +1000
Martin Schwenke <martin@meltin.net> wrote:

> Prefix labelling is currently only activated when monitoring "all"
> objects.  However, the output can still be confusing when monitoring
> more than 1 object, so enable prefix labels in this case.
> 
> Signed-off-by: Martin Schwenke <martin@meltin.net>

I understand where you are coming from, but changing the output format
might break people with scripts doing parsing the current format.

Since there is already a flag to ip monitor to put on prefix labels,
why not just use that if you need to?

This seems like a change likely to upset more people than it pleases.
