From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH]: TCP + SACK + skb processing latency
Date: Wed, 27 Feb 2008 09:34:14 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0802270926490.21342@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0802011756140.31652@kivilampi-30.cs.helsinki.fi>
 <20080226.224555.239440389.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1373397800-1204097654=:21342"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34976 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844AbYB0HeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 02:34:17 -0500
In-Reply-To: <20080226.224555.239440389.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1373397800-1204097654=:21342
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 26 Feb 2008, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Fri, 1 Feb 2008 18:18:02 +0200 (EET)
> 
> Interesting idea... it is like a baby step towards a more efficient
> write queue data management facility :-)
> 
> > I'd appreciate if somebody with more knowledge about skb internals could 
> > take a look at the relevant parts (mainly skb_shift) and confirm that 
> > doing all this I'm trying to do is allowed :-).
> 
> It looks good.  You never have to worry about skb's in the write queue
> having headers, ever.  They only contain data.

Thanks for taking a look, I've mostly added the missing bits to the
TCP side so I hope I can soon begin some testing with it... :-)

-- 
 i.
---696243703-1373397800-1204097654=:21342--
