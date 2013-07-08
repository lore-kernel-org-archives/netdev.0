From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: updates to syncookies - timestamps not needed any more (freebsd)
Date: Mon, 08 Jul 2013 09:39:38 -0700
Message-ID: <1373301578.4979.115.camel@edumazet-glaptop>
References: <20130708160421.GA9763@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:63153 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534Ab3GHQjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 12:39:40 -0400
Received: by mail-ob0-f178.google.com with SMTP id fb19so5736217obc.37
        for <netdev@vger.kernel.org>; Mon, 08 Jul 2013 09:39:40 -0700 (PDT)
In-Reply-To: <20130708160421.GA9763@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-08 at 18:04 +0200, Hannes Frederic Sowa wrote:
> Interesting patch by Andre Opperann of FreeBSD:
> <http://lists.freebsd.org/pipermail/freebsd-net/2013-July/035999.html>
> 
> Greetings,


Switching from SHA to SipHash would be nice, if SipHash is secure
enough.

(We do not use MD5 but SHA for syncookies)
