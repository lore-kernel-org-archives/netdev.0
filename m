From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 2.6.23-rc6 Resending] NETWORKING : Edge Triggered EPOLLOUT
 events get missed for TCP sockets
Date: Wed, 19 Sep 2007 22:43:21 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0709191701050.2989@alien.or.mcafeemobile.com>
References: <331107.71046.qm@web53704.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Nagendra Tomar <tomer_iisc@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:56844 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753309AbXITFn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 01:43:29 -0400
Received: from alien.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.25 ESMTP Server]
	id <S24EAF1> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Thu, 20 Sep 2007 01:43:28 -0400
In-Reply-To: <331107.71046.qm@web53704.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Sep 2007, Nagendra Tomar wrote:

> Definitely not ! 
> 
> The point is that the "tcp write space available" 
> wakeup does not get called if SOCK_NOSPACE bit is not set. This was
> fine when the wakeup was merely a wakeup (since SOCK_NOSPACE bit 
> indicated that someone really cared abt the wakeup). Now after the
> introduction of callback'ed wakeups, we might have some work to
> do inside the callback even if there is nobody interested in the wakeup
> at that point of time. 
> 
> In this particular case the ep_poll_callback is not getting called and
> hence the socket fd is not getting added to the ready list.

I know, I saw the patch. I was just commenting the point where DaveM was 
heading to ;)
This things needs to be looked at a little bit more deeply.


- Davide


