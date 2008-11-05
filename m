From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tbench wrt. loopback TSO
Date: Wed, 5 Nov 2008 15:33:37 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811051527210.23792@wrl-59.cs.helsinki.fi>
References: <20081105114900.GA18691@ioremap.net> <20081105.035454.87914782.davem@davemloft.net>
 <Pine.LNX.4.64.0811051355550.23792@wrl-59.cs.helsinki.fi>
 <20081105.040943.03609283.davem@davemloft.net>
 <Pine.LNX.4.64.0811051414250.23792@wrl-59.cs.helsinki.fi>
 <20081105130405.GA26435@ioremap.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-262672938-1225892017=:23792"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, efault@gmx.de, mingo@elte.hu,
	a.p.zijlstra@chello.nl, Herbert Xu <herbert@gondor.apana.org.au>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47953 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653AbYKENdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 08:33:39 -0500
In-Reply-To: <20081105130405.GA26435@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-262672938-1225892017=:23792
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 5 Nov 2008, Evgeniy Polyakov wrote:

> On Wed, Nov 05, 2008 at 02:25:57PM +0200, Ilpo Järvinen (ilpo.jarvinen@helsinki.fi) wrote:
> > The problem is that we'd need to _resegment with the next skb_ since the 
> > mss boundary and skb boundary would basically constantly be running 
> > out-of-sync. That won't get done currently by anything.
> 
> Btw, what's that wrong if there will be sub-mss frame per tso frame?

I personally don't consider that to be a big deal... I suppose some see
it as bad thing because of the slightly larger header vs data ratio...
Which is significant only if you can saturate the link (or have unbounded 
bandwidth such as with lo), so slower links are more affected than high 
speed ones...

-- 
 i.
---696208474-262672938-1225892017=:23792--
