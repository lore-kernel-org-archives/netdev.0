From: Steve.Glendinning@smsc.com
Subject: Re: [patch 2.6.29-rc] usbnet: allow type check of devdbg arguments in
 non-debug build
Date: Tue, 20 Jan 2009 10:56:09 +0000
Message-ID: <OF3908A70A.0C947A82-ON80257544.003AA7DB-80257544.003C295C@smsc.com>
References: <200901192111.48432.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, ian.saturley@smsc.com,
	jeff@garzik.org, jussi.kivilinna@mbnet.fi, netdev@vger.kernel.org
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:3482 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756331AbZATK7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2009 05:59:08 -0500
In-Reply-To: <200901192111.48432.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Brownell <david-b@pacbell.net> wrote on 20/01/2009 05:11:48:
> On Monday 19 January 2009, David Miller wrote:
> > > Maybe, but that's after all part of why we want this kind
> > > of patch merged ... after the first gremlines are fixed!
> > 
> > When you submit a change like this that can have
> > potential warning and build failure effects across
> > the entire tree, the onus is on you to do an
> > allmodconfig sanity check build or similar and
> > add any necessary fixes to your change.
> 
> It's actually Steve's patch ... Steve?
> 

Sorry, my bad - I tested compilation of usbnet drivers in
drivers/net/usb but missed this wireless usbnet driver hiding
in drivers/net/wireless.  allmodconfig was what i was looking
for, thanks David!

I've fixed this compilation breakage now, updated patchset to
follow.

Steve
