From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [NET] warn when accounting an skb that already has a
 destructor
Date: Mon, 5 May 2008 14:58:01 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805051452300.1888@wrl-59.cs.helsinki.fi>
References: <1209925940.3655.17.camel@johannes.berg>
 <20080505.002006.225975612.davem@davemloft.net>  <1209972675.3655.15.camel@johannes.berg>
  <20080505.004017.247102504.davem@davemloft.net>
 <Pine.LNX.4.64.0805051241240.21115@wrl-59.cs.helsinki.fi>
 <1209987453.3655.40.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1834832196-1209988681=:1888"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49887 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbYEEL6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 07:58:05 -0400
In-Reply-To: <1209987453.3655.40.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1834832196-1209988681=:1888
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 5 May 2008, Johannes Berg wrote:

> On Mon, 2008-05-05 at 12:43 +0300, Ilpo Järvinen wrote:
> > On Mon, 5 May 2008, David Miller wrote:
> > 
> > > From: Johannes Berg <johannes@sipsolutions.net>
> > > Date: Mon, 05 May 2008 09:31:15 +0200
> > > 
> > > > If we decide to uninline those functions for another reason (used too
> > > > much, code size, ...) then we can still do that.
> > > 
> > > Agreed.
> > 
> > According to my measurements the size bloat of those two is
> > (x86/32bit, gcc 4.1.2 redhat something):
> > 
> > -1091  40 funcs, 89 +, 1180 -, diff: -1091 --- skb_set_owner_r
> > -495  46 funcs, 70 +, 565 -, diff: -495 --- skb_set_owner_w
> 
> So do we want to out-line them? I don't really know the scale involved.
> If so I can resubmit this patch with them outlined and the warnings
> added 

...It's not among the topmost of them, here's the full list:

http://www.cs.helsinki.fi/u/ijjarvin/inlines/sorted.v2.6.25-rc2-mm1

> (but did you account for the EXPORT_SYMBOL space?)

Not really. I don't even know how to measure such...

-- 
 i.
---696208474-1834832196-1209988681=:1888--
