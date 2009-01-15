From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
	2.6.28
Date: Thu, 15 Jan 2009 10:38:38 +0000
Message-ID: <20090115103838.GF5461@ff.dom.local>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <496AF0CE.7060406@trash.net> <2105.192.168.1.3.1231753688.squirrel@webmail.decimal.pt> <200901140353.49730.denys@visp.net.lb> <2053.87.196.219.155.1231961820.squirrel@webmail.decimal.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Jorge Bastos <mysql.jorge@decimal.pt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f31.google.com ([209.85.219.31]:50493 "EHLO
	mail-ew0-f31.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763946AbZAOKio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 05:38:44 -0500
Received: by ewy12 with SMTP id 12so324602ewy.13
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2009 02:38:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <2053.87.196.219.155.1231961820.squirrel@webmail.decimal.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 07:37:00PM -0000, Jorge Bastos wrote:
...
> > My traffic is "transit", means just passing router. I guess if it is
> > correct,
> > there must be statement about difference in locally generated traffic and
> > transit traffic. TSO/GSO offloading i guess not done for "passing thru"
> > traffic.
> >
> 
> Denys,
> Not correct, my traffic is transit as you say.
> That is a public IP and that traffic is for public access only.
> 

Yes, TSO/GSO affect shaping of any traffic going through (usually out)
a device with these options enabled. The main issue here was TBF which
treats it different (drops too big packets) than e.g. HTB.

Jarek P.
