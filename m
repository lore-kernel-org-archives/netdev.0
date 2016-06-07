From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable - rhashtable_insert_fast failed
Date: Tue, 7 Jun 2016 22:16:57 +0800
Message-ID: <20160607141656.GB2237@gondor.apana.org.au>
References: <5751E702.5040909@gmx.de>
 <20160604073527.GE29740@orbyte.nwl.cc>
 <20160606035718.GA19559@gondor.apana.org.au>
 <5756D69E.1080402@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phil Sutter <phil@nwl.cc>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: Helge Deller <deller@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:42811 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752727AbcFGORN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 10:17:13 -0400
Content-Disposition: inline
In-Reply-To: <5756D69E.1080402@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2016 at 04:13:50PM +0200, Helge Deller wrote:
>
> What warnings do you mean specifically? Some specific CONFIG_ option ?

Look for GFP_NOWARN in lib/rhashtable.c and delete it.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
