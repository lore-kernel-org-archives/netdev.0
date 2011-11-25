From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP fast retransmit
Date: Fri, 25 Nov 2011 18:57:14 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1111251843220.7144@melkinpaasi.cs.helsinki.fi>
References: <2D9E1426-D432-4D08-BF28-FD2615AAEDBA@mpi-bpc.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Esztermann, Ansgar" <Ansgar.Esztermann@mpi-bpc.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35506 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920Ab1KYQ5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 11:57:16 -0500
In-Reply-To: <2D9E1426-D432-4D08-BF28-FD2615AAEDBA@mpi-bpc.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Nov 2011, Esztermann, Ansgar wrote:

> [originally posted to lkml]
> Hello list,
> 
> is there some documentation available on TCP fast retransmit? There seem 
> to be quite a lot of descriptions -- from informal to scholarly papers 
> -- on the various algorithms available to calculate the proper size of 
> the congestion window, but I have been unable so far to find out *when* 
> a fast retransmit is triggered. RFC 2581 states the third dupACK 
> "should" do it, and this seems to be quoted fairly often. However, I can 
> easily produce connections that fail to perform fast retransmit even 
> after 5 dupACKs. Some people mention Linux uses a different (presumable 
> more sophisticated) algorithm to trigger fast retransmits, but no-one 
> seems to elaborate.

With SACKs dupacks are meaningless (just in case you craft them). Instead 
SACK blocks matter... but how exactly depends of if FACK is in use or 
not... with FACK also holes (segments not reported by sack) below highest 
SACK count.

-- 
 i.
