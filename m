From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [Bug 13639] New: tun regression
Date: Sun, 28 Jun 2009 17:32:08 -0300
Message-ID: <20090628203208.GA3022@ghostprotocols.net>
References: <bug-13639-60@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Hartkopp <olver@hartkopp.net>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>, bugzilla-daemon@bugzilla.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, alessandro.guido@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:50110 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751102AbZF1UcS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jun 2009 16:32:18 -0400
Content-Disposition: inline
In-Reply-To: <bug-13639-60@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Sat, Jun 27, 2009 at 10:23:04PM +0000, bugzilla-daemon@bugzilla.kernel.org escreveu:
> http://bugzilla.kernel.org/show_bug.cgi?id=13639
> 
>            Summary: tun regression
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.31-rc1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: alessandro.guido@gmail.com
>         Regression: Yes
> 
> 
> ssh doesn't work with OpenVPN anymore but ping does.
> 
> I've bisected it down to
> 
> Commit d55d87fdff8252d0e2f7c28c2d443aee17e9d70f
> net: Move rx skb_orphan call to where needed

DNS as well doesn't work here, only ping, reverted the above cset and
got it working again (vpnc here).

- Arnaldo
