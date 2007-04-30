From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [RFC] [TCP]: Catch skb with S+L bugs earlier
Date: Mon, 30 Apr 2007 11:09:44 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0704301100410.29336@kivilampi-30.cs.helsinki.fi>
References: <20070430.002837.27783394.davem@davemloft.net>
 <Pine.LNX.4.64.0704301037080.29336@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0704301045100.29336@kivilampi-30.cs.helsinki.fi>
 <20070430.005737.24335918.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1666965684-1177920584=:29336"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45941 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423157AbXD3IJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 04:09:47 -0400
In-Reply-To: <20070430.005737.24335918.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1666965684-1177920584=:29336
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 30 Apr 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 30 Apr 2007 10:49:21 +0300 (EEST)
> 
> > On Mon, 30 Apr 2007, Ilpo Järvinen wrote:
> > 
> > > On Mon, 30 Apr 2007, David Miller wrote:
> > > 
> > > > From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> > > > Date: Wed, 28 Mar 2007 17:02:47 +0300 (EEST)
> > > > 
> > > > > SACKED_ACKED and LOST are mutually exclusive, thus this
> > > > > condition is bug with SACK (IMHO). NewReno, however, could get
> > 
> > [...snip...]
> > 
> > > > I've applied this, thanks for your patience.
> > 
> > ...heh... I was getting a bit unsure whether you still had them...
> > 
> > > I think I sent an updated version later (hopefully I reach you before 
> > > you push these out :-)), which made the BUG_ON unconditional (I used it 
> > > instead of BUG_TRAP as it seems to be generic machinery for handling 
> > > these).
> > 
> > Here:
> >   http://marc.info/?l=linux-netdev&m=117648826715609&w=2
> 
> Thanks, I'll swap in that version of the patch.

Hmm, just looked a bit more, is the left_out really that necessary as a 
separate variable? It's always possible to calculate it in the places 
where it is needed and users are quite few after all (basically the 
packets_in_flight callers)... ...it just would save some bytes in
tcp_sock... ;-)


-- 
 i.
---696243703-1666965684-1177920584=:29336--
