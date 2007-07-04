From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Beyond 64K TCP connections limit per IP-address
Date: Wed, 4 Jul 2007 13:36:58 +0400
Message-ID: <20070704093658.GD15210@2ka.mipt.ru>
References: <7e63f56c0707040050k7d1a9daeq276d7d924ef802e8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: NetDev <netdev@vger.kernel.org>
To: Robert Iakobashvili <coroberti@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:36482 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757242AbXGDJhJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 05:37:09 -0400
Content-Disposition: inline
In-Reply-To: <7e63f56c0707040050k7d1a9daeq276d7d924ef802e8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 04, 2007 at 09:50:31AM +0200, Robert Iakobashvili (coroberti@gmail.com) wrote:
> If I am correct, a TCP server can make up to
> 64K accepts for a port at a single IP-address.

No, it is essentially unlimited - linux uses local/remote addr/port
tuples for hash chains, so there is no per-addr limits.
If there is some kind of binds, then yes, only 64k ports per address.


-- 
	Evgeniy Polyakov
