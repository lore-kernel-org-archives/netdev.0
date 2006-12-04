From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [NET_SCHED]: cls_fw: fix NULL pointer dereference
Date: Mon, 4 Dec 2006 17:28:23 +0100
Message-ID: <20061204162823.GQ8693@postel.suug.ch>
References: <45744016.8080707@trash.net> <1165249502.3643.9.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:38067 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937094AbWLDQ2D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 11:28:03 -0500
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1165249502.3643.9.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-12-04 11:25
> On Mon, 2006-04-12 at 16:34 +0100, Patrick McHardy wrote:
> > Fix a regression from my nfmark mask patch for cls_fw.
> > 
> > Thomas, Jamal, do you have an idea what this "old method" stuff
> > is used for? It seems it is only used during the below mentioned
> > race.
> 
> AFAIK, that has been there forever. Alexey may know. I am not
> sure if removing it will break any scripts etc.

You mean the scripts get upset when the kernel oopses?

Very good spotting Patrick!
