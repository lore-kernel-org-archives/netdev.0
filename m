From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] Phonet: sockets list through proc_fs
Date: Mon, 20 Jul 2009 15:00:40 +0200
Message-ID: <1248094840.4549.119.camel@violet>
References: <200907201247.23020.remi.denis-courmont@nokia.com>
	 <20090720.034328.193709571.davem@davemloft.net>
	 <1248091650.4549.107.camel@violet>
	 <200907201549.30870.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37588 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752703AbZGTNBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 09:01:12 -0400
In-Reply-To: <200907201549.30870.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Remi,

> > > > On Monday 20 July 2009 13:21:01 ext Marcel Holtmann wrote:
> > > >> > It's just like most network protocols exposing their sockets list in
> > > >> > /proc/net. Debugging/monitoring indeed.
> > > >>
> > > >> I think that for new protocols, we should not do this anymore and just
> > > >> use debugfs. Since that is exactly its job.
> > > >
> > > > Requiring debugfs for something like 'netstat' sounds restrictive to
> > > > me...
> > >
> > > Me too.
> >
> > hold on, what has netstat to do with Phonet support?
> 
> First, I said "*like* netstat". Second, *net*stat has at least as much to do 
> with Pho*net* than it has with Unix sockets. I'm interested in monitoring 
> userland usage of Phonet sockets, not so much in debugging the kernel-mode 
> Phonet stack. I am not convinced that debugfs is the right tool at all here - 
> regardless whether we extend netstat or write a Phonet-specific tool.

in the end it is up to Dave, however I would put these things into
debugfs. Note that even something like mac80211 still provides a
wireless file here while most debugging is nowaydays in debugfs and it
might be better removed.

Regards

Marcel


