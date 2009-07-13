From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] gre: copy ToS/DiffServ bits to outer IP header
Date: Mon, 13 Jul 2009 09:07:43 -0700
Message-ID: <20090713090743.27e1b8ea@nehalam>
References: <20090713133225.GA20946@urbino.open.ch>
	<20090713083303.61a59b63@nehalam>
	<20090713160142.GA9252@urbino.open.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	kaber@trash.net
To: Andreas Jaggi <aj@open.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49939 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756410AbZGMQHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jul 2009 12:07:50 -0400
In-Reply-To: <20090713160142.GA9252@urbino.open.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Jul 2009 18:01:42 +0200
Andreas Jaggi <aj@open.ch> wrote:

> On Mon, Jul 13, 2009 at 08:33:03AM -0700, Stephen Hemminger wrote:
> > Why make it an option? Sounds like it should always be on.
> 
> In some scenarios people might want to set the ToS value for all
> GRE tunnel packets to a fixed value (cf. ip tunnel tos option).

Having more options, does not help users.  Why not just do that
with iptables or classifiers?
