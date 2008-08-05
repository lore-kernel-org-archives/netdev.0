From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: thousands of classes, e1000 TX unit hang
Date: Tue, 5 Aug 2008 18:48:07 +0200
Message-ID: <20080805164807.GC2526@ami.dom.local>
References: <20080805110453.GA6541@ff.dom.local> <200808051413.58795.denys@visp.net.lb> <20080805122340.GB6541@ff.dom.local> <200808051707.25601.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:27961 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754135AbYHEQrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 12:47:45 -0400
Received: by ug-out-1314.google.com with SMTP id h2so88385ugf.16
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2008 09:47:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808051707.25601.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 05, 2008 at 05:07:25PM +0300, Denys Fedoryshchenko wrote:
> On Tuesday 05 August 2008, Jarek Poplawski wrote:
> > reported often to the list (I remember once). Some workaround could be
> > probably deleting individual classes (and filters) to give away a lock
> > and soft interrupts for a while), before deleting the root, but I
> > didn't test this. 
> Btw even if i optimize my scripts, still when ppp interface going down and 
> disappearing - all classes will be deleted, and system locked up for short 
> time (with all related TX hang, packetloss and etc).

Are you sure you can't let pppd to run this script when the link goes
down?

Jarek P.
