From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/1] Fix getsockname (ipv4/ipv6)
Date: Mon, 26 Jan 2009 23:37:33 +0100
Message-ID: <20090126223733.GB1922@Chamillionaire.breakpoint.cc>
References: <20090126220931.A8F0154A11@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: John Reumann <reumann.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:42959 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751957AbZAZWhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 17:37:34 -0500
Content-Disposition: inline
In-Reply-To: <20090126220931.A8F0154A11@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Reumann <reumann.linux@gmail.com> wrote:
> This change will return ENOSPC if the return address provided by the caller of getsockname
>  is not sufficiently large to hold the return value.

Those interfaces allow applications to query how large the sockaddr storage needs to
be by checking *addrlen after a successful call.

> This is consistent with the rest of the
>  API. However, there are some implemenations that copy only as many bytes of sockaddr from the
>  kernel to user-space as specified in the *addrlen attribute.  (1) This wasn't the behavior now

It is, and it has been for ages.
