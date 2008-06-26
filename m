From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Sending big Netlink messages to userspace
Date: Thu, 26 Jun 2008 12:01:10 +0200
Message-ID: <20080626100110.GL20815@postel.suug.ch>
References: <f4845fc0806240938h36d275ect109fd5f5414cba37@mail.gmail.com> <f4845fc0806241118u397a17e3qbe09f5d04a7e5035@mail.gmail.com> <4861282C.4000208@trash.net> <20080625104401.GJ20815@postel.suug.ch> <f4845fc0806251156m5c6405c9w65cd126c1e5551ce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Vince Busam <vbusam@google.com>
To: Julius Volz <juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:43291 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752162AbYFZKAw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2008 06:00:52 -0400
Content-Disposition: inline
In-Reply-To: <f4845fc0806251156m5c6405c9w65cd126c1e5551ce@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Julius Volz <juliusv@google.com> 2008-06-25 20:56
> So userspace now gets one callback invocation per part of a multipart
> message. I guess it's not possible to aggregate the data into just one
> callback invocation?

Typically the aggregation is done when multipart messages are fed into
a cache/collection which is then provided to the caller. This requires
the caller to implement object and cache operations and is based on
the assumption that a single netlink message represents a single object.

In your case I'd suggest to do the aggregation on your own.
