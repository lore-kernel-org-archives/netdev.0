From: David Miller <davem@davemloft.net>
Subject: Re: setsockopt option struct with an address?
Date: Thu, 01 Oct 2009 13:30:11 -0700 (PDT)
Message-ID: <20091001.133011.43582402.davem@davemloft.net>
References: <c0a09e5c0910011317n76fba7e8q6de7dd35268654b9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andy.grover@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58593
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751287AbZJAU3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 16:29:51 -0400
In-Reply-To: <c0a09e5c0910011317n76fba7e8q6de7dd35268654b9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Grover <andy.grover@gmail.com>
Date: Thu, 1 Oct 2009 13:17:03 -0700

> Or should the added member be a struct sockaddr, or a sockaddr_in, or
> a sockaddr_storage, or what? And should it be a pointer to that
> struct, or embedded?

You probably should use sockaddr_storage, I mean you will want to
support ipv6 at some point right? :-)
