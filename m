From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 0/2] New socket API: recvmmsg
Date: Wed, 20 May 2009 17:30:36 -0700 (PDT)
Message-ID: <20090520.173036.33695641.davem@davemloft.net>
References: <20090520230642.GA5956@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vanhoof@redhat.com, williams@redhat.com
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51157
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757408AbZEUAai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 20:30:38 -0400
In-Reply-To: <20090520230642.GA5956@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 20 May 2009 20:06:42 -0300

> 	The following two patches, that I cooked today and haven't
> properly benchmarked, implements a new socket syscall, recvmmsg, that
> stands for receive multiple messages, in one call.

As I discussed with Arnaldo on IRC I am OK with this kind of
interface.

And, also, I think we need to seriously consider the patches
posted by others a few weeks ago that allowed sending to
multiple receivers in one system call.

The old adage about syscalls being cheap no longer holds when
we're talking about traversing all the way into the protocol
stack socket code every call, taking the socket lock every
time, etc.  So we really do need these batching variants of
I/O calls, or something similar.
