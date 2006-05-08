From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [RFC 1/3] [IPSEC] xfrm: Undo afinfo lock proliferation
Date: Mon, 8 May 2006 15:58:10 +0200
Message-ID: <200605081558.10528.netdev@axxeo.de>
References: <1145343829.44448f556684c@webmail.hiit.fi> <200605081522.14524.netdev@axxeo.de> <20060508134729.GA13089@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:55941 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S1751256AbWEHN6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 09:58:31 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060508134729.GA13089@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

Herbert Xu schrieb:
> It's just moving an existing line down if you look further up in
> the patch.  Of couse I would have nothing against a patch that
> replaced 256 with IPPROTO_MAX or something.

Ahh, that's the actual meaning here... 

> However, I prefer to not mix clean-ups with substantive changes so
> if you have the time please post a separate patch for this.  Otherwise
> I'll do a patch when I resubmit this.

Would be nice to include such a patch in this patchset, since you seem
to be able to decipher that magic value :-)


Thanks & Regards

Ingo Oeser
