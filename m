From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] packet: tpacket_v3: do not trigger bug() on wrong
 header status
Date: Tue, 07 May 2013 14:56:27 -0700
Message-ID: <1367963787.13473.11.camel@edumazet-glaptop>
References: <1367585820-2674-1-git-send-email-dborkman@redhat.com>
	 <CAAsGZS7TVr2YX8H8EQRqk4gDwNMQiaOkjhwCuLM_27RqB6+QgQ@mail.gmail.com>
	 <518968DF.9070008@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: chetan loke <loke.chetan@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:61098 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752402Ab3EGV4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 17:56:30 -0400
Received: by mail-pd0-f181.google.com with SMTP id p11so734172pdj.12
        for <netdev@vger.kernel.org>; Tue, 07 May 2013 14:56:29 -0700 (PDT)
In-Reply-To: <518968DF.9070008@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-07 at 22:49 +0200, Daniel Borkmann wrote:

> Right, and now we treat people who write crappy applications with BUG?
> 
> BUG is only for consistency checks *within* the kernel and not meant to
> be triggered on purpose from user space.

+1
