From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] act_mirred: combine duplicate code
Date: Wed, 30 Jun 2010 06:24:02 -0400
Message-ID: <1277893442.3509.16.camel@bigi>
References: <1277888098-27632-1-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:42476 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031Ab0F3KYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 06:24:07 -0400
Received: by qwi4 with SMTP id 4so228494qwi.19
        for <netdev@vger.kernel.org>; Wed, 30 Jun 2010 03:24:05 -0700 (PDT)
In-Reply-To: <1277888098-27632-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


removed lkml

On Wed, 2010-06-30 at 16:54 +0800, Changli Gao wrote:
> act_mirred: combine duplicate code
> 
> tcf_bstats is updated in any way, so we can do it earlier to reduce the size of
> the code.

There is one condition when !(dev->flags & IFF_UP) where we dont update
the stats in current code. This changes with your patch. 
It would make sense to actually update at that point (as you do) and
additionally increment some other counter to track that like
m->tcf_qstats.drops. I suggest resubmit with that change and add my
signed-off.

cheers,
jamal

