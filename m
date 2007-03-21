From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] netlink: no need to crash if table does not exist.
Date: Wed, 21 Mar 2007 13:58:47 +0300
Message-ID: <20070321105847.GA18221@2ka.mipt.ru>
References: <20070321104456.GA2637@2ka.mipt.ru> <46010EF5.6010306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:40573 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752178AbXCUK65 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 06:58:57 -0400
Content-Disposition: inline
In-Reply-To: <46010EF5.6010306@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 21, 2007 at 11:54:45AM +0100, Patrick McHardy (kaber@trash.net) wrote:
> Evgeniy Polyakov wrote:
> > We would already do that on init.
> > Some things become very confused, when nl_table is not used to store
> > netlink sockets.
> 
> 
> Its unnecessary, but I don't understand what the problem is.
> Why would it be NULL and what gets confused?

There is no problem as-is, but I implement unified cache for different
sockets (currently tcp/udp/raw and netlink are supported), which does
not use that table, so I currently wrap all access code into special
ifdefs, this one can be wrapped too, but since it is not needed, it
saves couple of lines of code.

-- 
	Evgeniy Polyakov
