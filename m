From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [NET] warn when accounting an skb that already has a
 destructor
Date: Tue, 6 May 2008 11:39:11 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805060951290.26897@wrl-59.cs.helsinki.fi>
References: <1209972675.3655.15.camel@johannes.berg>
 <20080505.004017.247102504.davem@davemloft.net>
 <Pine.LNX.4.64.0805051241240.21115@wrl-59.cs.helsinki.fi>
 <20080505.120811.211603587.davem@davemloft.net> <20080505215744.GD21070@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1758750675-1210056746=:26897"
Cc: David Miller <davem@davemloft.net>, johannes@sipsolutions.net,
	Netdev <netdev@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36800 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753653AbYEFIjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 04:39:15 -0400
In-Reply-To: <20080505215744.GD21070@ghostprotocols.net>
Content-ID: <Pine.LNX.4.64.0805061107430.1888@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1758750675-1210056746=:26897
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0805061107431.1888@wrl-59.cs.helsinki.fi>

On Mon, 5 May 2008, Arnaldo Carvalho de Melo wrote:

> Em Mon, May 05, 2008 at 12:08:11PM -0700, David Miller escreveu:
> > From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> > Date: Mon, 5 May 2008 12:43:25 +0300 (EEST)
> > 
> > > On Mon, 5 May 2008, David Miller wrote:
> > > 
> > > > From: Johannes Berg <johannes@sipsolutions.net>
> > > > Date: Mon, 05 May 2008 09:31:15 +0200
> > > > 
> > > > > If we decide to uninline those functions for another reason (used too
> > > > > much, code size, ...) then we can still do that.
> > > > 
> > > > Agreed.
> > > 
> > > According to my measurements the size bloat of those two is
> > > (x86/32bit, gcc 4.1.2 redhat something):
> > > 
> > > -1091  40 funcs, 89 +, 1180 -, diff: -1091 --- skb_set_owner_r
> > > -495  46 funcs, 70 +, 565 -, diff: -495 --- skb_set_owner_w
> > 
> > That's not too bad, but adding the WARN_ON() we're discussing
> > will plump that up a bit, percentage wise, which is why I
> > said we should inline it in such a case.
> 
> s/inline/uninline/g
> 
> According to some long e-mail today its worth ~198 unexport patches! 8-)

...and there would be hundreths of similar with that order of magnitude,
thus one could, for starters, multiply that by ~200 or so... 8-D

-- 
 i.
---696208474-1758750675-1210056746=:26897--
