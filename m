From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Beyond 64K TCP connections limit per IP-address
Date: Wed, 4 Jul 2007 12:06:52 +0200
Message-ID: <20070704120652.262380eb.dada1@cosmosbay.com>
References: <7e63f56c0707040050k7d1a9daeq276d7d924ef802e8@mail.gmail.com>
	<20070704093658.GD15210@2ka.mipt.ru>
	<7e63f56c0707040240p4ec962fajd93074909b07ea03@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	NetDev <netdev@vger.kernel.org>
To: "Robert Iakobashvili" <coroberti@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:48380 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756723AbXGDKHL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 06:07:11 -0400
In-Reply-To: <7e63f56c0707040240p4ec962fajd93074909b07ea03@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Jul 2007 11:40:48 +0200
"Robert Iakobashvili" <coroberti@gmail.com> wrote:

> On 7/4/07, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> > On Wed, Jul 04, 2007 at 09:50:31AM +0200, Robert Iakobashvili (coroberti@gmail.com) wrote:
> > > If I am correct, a TCP server can make up to
> > > 64K accepts for a port at a single IP-address.
> >
> > No, it is essentially unlimited - linux uses local/remote addr/port
> > tuples for hash chains, so there is no per-addr limits.
> > If there is some kind of binds, then yes, only 64k ports per address.
> 
> Thanks, it clarified me the issue.
> Probably, I am experiencing some local problem with
> the web-server I am using for tests.

If your setup is :

Server A with one IP address listening to port 80

'Client B' with one IP address, trying to open many sockets to A (port 80)

Then yes you have a 64k limit for this particular client B. Just add 15 more clients (or 16 IP addresses on B) if you really want to stress A ;)

