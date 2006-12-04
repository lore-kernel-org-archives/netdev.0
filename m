From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][GENETLINK] move command capabilities  to flags
Date: Mon, 04 Dec 2006 12:48:04 -0500
Message-ID: <1165254484.3643.29.camel@localhost>
References: <1165060612.3564.8.camel@localhost>
	 <20061204092041.GN8693@postel.suug.ch> <1165237269.3664.15.camel@localhost>
	 <20061204163115.GR8693@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.224]:27724 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934423AbWLDRsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 12:48:07 -0500
Received: by wr-out-0506.google.com with SMTP id i7so1646838wra
        for <netdev@vger.kernel.org>; Mon, 04 Dec 2006 09:48:07 -0800 (PST)
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061204163115.GR8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-04-12 at 17:31 +0100, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-12-04 08:01
> > The savings bytes is one aspect; the other is the cleanliness.
> > transfering a boolean in that many bits is a little of overkill.
> > I think it is better to fix it now than later.
> > I know you mentioned libnl uses it. But that is something you can change
> > on your side. I dont know of any other app that uses it. 
> 
> Right but if some distro is based on exactly 2.6.19 the specific libnl
> parts won't work at all for a long time.
> 

We can resolve that by uping the version for the controller.
User will use that a signal.

> > > If you
> > > really want to do it, remove the obsoleted attribute types, I don't
> > > like dead bodies laying around :-)
> > 
> > I could resend the patch getting rid of those definitions. 
> 
> OK, I can live with it, I don't care for the breakage much.

cool - will send a patch later.

cheers,
jamal

