From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC][GENETLINK] move command capabilities  to flags
Date: Mon, 4 Dec 2006 19:00:00 +0100
Message-ID: <20061204180000.GU8693@postel.suug.ch>
References: <1165060612.3564.8.camel@localhost> <20061204092041.GN8693@postel.suug.ch> <1165237269.3664.15.camel@localhost> <20061204163115.GR8693@postel.suug.ch> <1165254484.3643.29.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:38506 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758916AbWLDR7k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 12:59:40 -0500
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1165254484.3643.29.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-12-04 12:48
> On Mon, 2006-04-12 at 17:31 +0100, Thomas Graf wrote:
> > * jamal <hadi@cyberus.ca> 2006-12-04 08:01
> > > The savings bytes is one aspect; the other is the cleanliness.
> > > transfering a boolean in that many bits is a little of overkill.
> > > I think it is better to fix it now than later.
> > > I know you mentioned libnl uses it. But that is something you can change
> > > on your side. I dont know of any other app that uses it. 
> > 
> > Right but if some distro is based on exactly 2.6.19 the specific libnl
> > parts won't work at all for a long time.
> > 
> 
> We can resolve that by uping the version for the controller.
> User will use that a signal.

Good idea, makes me happy :-) please do that in your patch as well.
