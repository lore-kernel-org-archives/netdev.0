From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Mon, 8 Sep 2008 19:38:42 +0400
Message-ID: <20080908153841.GA24683@2ka.mipt.ru>
References: <7e0dd21a0809050745w692328b7v6dd4e0adf59e9535@mail.gmail.com> <20080905145902.GA12762@2ka.mipt.ru> <7e0dd21a0809050830o7c1dcc2do68da5df9900fcfe8@mail.gmail.com> <20080905153811.GA3596@2ka.mipt.ru> <7e0dd21a0809050901q23d0b16xa1a9d0df2f36f6d8@mail.gmail.com> <20080905163446.GB10078@2ka.mipt.ru> <7e0dd21a0809080321p6b9e2bc7m73e2cdd57a8d58b8@mail.gmail.com> <20080908112629.GA26488@2ka.mipt.ru> <7e0dd21a0809080601lc250197wde17733522d03125@mail.gmail.com> <20080908152835.GA16834@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:57324 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752172AbYIHPjM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2008 11:39:12 -0400
Content-Disposition: inline
In-Reply-To: <20080908152835.GA16834@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 08, 2008 at 07:28:35PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> What is CPU usage on sender when it sends data via UDP sendfile()?

Actually we can determine the culprit via putting a loop into
udp_sendpage(), which will send the same data. if receiver will see the
same delayes, problem in the udp sending path, otherwise in splice code.

-- 
	Evgeniy Polyakov
