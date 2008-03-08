From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Sat, 8 Mar 2008 13:02:44 +0100
Message-ID: <20080308120244.GA3378@ami.dom.local>
References: <20080306214000.GC2876@ami.dom.local> <1204846839.4431.23.camel@localhost> <20080307075113.GA3912@ff.dom.local> <1204898002.4431.99.camel@localhost> <20080308084628.GA2749@ami.dom.local> <20080308085854.GB2749@ami.dom.local> <20080308101540.M65133@visp.net.lb> <20080308104322.GA3301@ami.dom.local> <20080308105250.GB3301@ami.dom.local> <20080308110611.M62976@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:13645 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754896AbYCHL4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 06:56:55 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1017037fga.17
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2008 03:56:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080308110611.M62976@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 08, 2008 at 01:09:10PM +0200, Denys Fedoryshchenko wrote:
> Seems "try 2" helped. lockdep is not triggered anymore. I test on 3 different 
> servers for now.
> I will test more deeply and on more servers.

Fine! So, let's wait yet... (No need to hurry.)

BTW, I thought about those earlier probably stack overflow problems,
and I wonder if using action ipt couldn't be blamed here. Sometimes
it seems to be unnecessary, so maybe you could try if re-doing some
filter rules can help.

Jarek P.
