From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: stop endless flood about dst entry refcount
 underflow or overflow
Date: Tue, 14 Jul 2015 14:26:07 +0200
Message-ID: <1436876767.1374.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150714114305.17434.53731.stgit@buzz>
	 <1436875454.1374.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <55A4FD76.7050606@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33050 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbbGNM0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 08:26:11 -0400
Received: by widic2 with SMTP id ic2so36825404wid.0
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 05:26:09 -0700 (PDT)
In-Reply-To: <55A4FD76.7050606@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-07-14 at 15:15 +0300, Konstantin Khlebnikov wrote:

> Simple warn-once will hide a lot of information which could be useful.
> Also dst entry leak is better than freeing actually active entry.

Then BUG_ON() .

Really, we need to fix leaks, not brown paper them.
