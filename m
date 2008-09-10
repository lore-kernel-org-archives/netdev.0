From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Wed, 10 Sep 2008 10:09:01 +0400
Message-ID: <20080910060900.GA12158@2ka.mipt.ru>
References: <7e0dd21a0809050830o7c1dcc2do68da5df9900fcfe8@mail.gmail.com> <20080905153811.GA3596@2ka.mipt.ru> <7e0dd21a0809050901q23d0b16xa1a9d0df2f36f6d8@mail.gmail.com> <20080905163446.GB10078@2ka.mipt.ru> <7e0dd21a0809080321p6b9e2bc7m73e2cdd57a8d58b8@mail.gmail.com> <20080908112629.GA26488@2ka.mipt.ru> <7e0dd21a0809080601lc250197wde17733522d03125@mail.gmail.com> <20080908152835.GA16834@2ka.mipt.ru> <20080908153841.GA24683@2ka.mipt.ru> <7e0dd21a0809091611q74b032ffw734d031a4def894b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:39584 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145AbYIJGJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2008 02:09:35 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0809091611q74b032ffw734d031a4def894b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann.

On Wed, Sep 10, 2008 at 01:11:31AM +0200, Johann Baudy (johaahn@gmail.com) wrote:
> We've performed more tests with additional and mandatory processes of
> our system. Bitrate and CPU performance were very very low. This
> result leads us to brainstorm on a new system design that meets
> specifications target. I'll continue these tests once new design
> ready.

If CPU usage was small, something slept somewhere, but so far we do not
know what and where. It would be great to understand, why sendfile() is
so slow with UDP especially when mempry bandwidth is very small, and
particulary understand if it is udp sending path itself or splice code.

> Concerning udp_sendpage() patch, if you agree, I will suggest this
> patch to the community in a new thread.

Sure, but please remove commented code lines instead of commenting them.

-- 
	Evgeniy Polyakov
