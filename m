From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Thu, 8 Jan 2009 07:16:51 +0000
Message-ID: <20090108071651.GA4496@ff.dom.local>
References: <20090106181559.GA29426@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Mansell <ben@zeus.com>, Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f31.google.com ([209.85.219.31]:57861 "EHLO
	mail-ew0-f31.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752620AbZAHHQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 02:16:58 -0500
Content-Disposition: inline
In-Reply-To: <20090106181559.GA29426@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06-01-2009 19:15, Willy Tarreau wrote:
...
> Ah, so you might also have discovered a few annoyances with the API, eg
> the fact that splice() returns after the first read in non-blocking mode,
> as well as the fact that it never returns zero on close, but -EAGAIN,
> which requires an additional recv(MSG_PEEK) to distinguish between a
> close and a lack of data. But I leave that for a later discussion, let's
> address the corruption issue first.

FYI, this should be just fixed:
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=4f7d54f59bc470f0aaa932f747a95232d7ebf8b1

Regards,
Jarek P.
