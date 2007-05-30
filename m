From: Thomas Graf <tgraf@suug.ch>
Subject: Re: netlink-based qdisc monitor?
Date: Wed, 30 May 2007 23:39:34 +0200
Message-ID: <20070530213934.GS521@postel.suug.ch>
References: <20070530191731.GA6040@falooley.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Jason Lunz <lunz@falooley.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:37604 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759654AbXE3VjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 17:39:13 -0400
Content-Disposition: inline
In-Reply-To: <20070530191731.GA6040@falooley.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Jason Lunz <lunz@falooley.org> 2007-05-30 12:17
> 
> I recall mention of a tool that could dynamically monitor kernel packet
> queues in linux using netlink, but I can't remember a unique enough name
> for good googling. Does this sound familiar to anyone? iirc it was
> written by Thomas Graf?

You probably mean `bmon'. It's a bit tricky to find a working
bmon + libnl version combination though. The library interface
is not stable yet and I haven't updated bmon in a while.
