From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: htb parallelism on multi-core platforms
Date: Sat, 18 Apr 2009 09:56:38 +0200
Message-ID: <20090418075637.GA2738@ami.dom.local>
References: <1239964844.21569.57.camel@blade.ines.ro> <49E905A2.7040402@gmail.com> <200904180321.50281.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Radu Rendec <radu.rendec@ines.ro>, netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f211.google.com ([209.85.218.211]:37285 "EHLO
	mail-bw0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263AbZDRH5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 03:57:04 -0400
Received: by bwz7 with SMTP id 7so440449bwz.37
        for <netdev@vger.kernel.org>; Sat, 18 Apr 2009 00:57:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200904180321.50281.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 18, 2009 at 03:21:50AM +0300, Denys Fedoryschenko wrote:
> On Saturday 18 April 2009 01:41:38 Jarek Poplawski wrote:
> > Radu Rendec wrote, On 04/17/2009 12:40 PM:
> > > Hi,
> >
> > Hi Radu,
> 
> > I don't know about anything (simple) for this, but I wonder if you
> > tried already any htb tweaking like htb_hysteresis module param or
> > burst/cburst class parameters to limit some maybe useless resolution/
> > overhead?
> Like adding HZ=1000 as environment variable in scripts :-)
> For me it helps....

Right, if you're using high resolution; there is a bug in tc, found by
Denys, which causes wrong (too low) defaults for burst/cburst.

> Also worth to try HFSC.

Yes, it seems to be especially interesting for 64 bit boxes.

Jarek P.
