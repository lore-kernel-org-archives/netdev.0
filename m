From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: PROBLEM: MTU of ipsec tunnel drops continuously until traffic
 stops
Date: Thu, 21 Jul 2016 11:12:56 +0200
Message-ID: <20160721091256.GG3775@gauss.secunet.com>
References: <1467598059395.19100@alliedtelesis.co.nz>
 <1467604370799.64629@alliedtelesis.co.nz>
 <20160704111202.GI12335@gauss.secunet.com>
 <c22799c2751348b8b2e5caddc9d13ece@svr-chch-ex1.atlnz.lc>
 <bba4a160385c4a36aecdd8d385e01c69@svr-chch-ex1.atlnz.lc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:44362 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751126AbcGUJM7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2016 05:12:59 -0400
Content-Disposition: inline
In-Reply-To: <bba4a160385c4a36aecdd8d385e01c69@svr-chch-ex1.atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Matt,

I've did some vti tests the last days, but I was unable to
reproduce it.

On Tue, Jul 19, 2016 at 05:49:06AM +0000, Matt Bennett wrote:
> On 07/05/2016 03:55 PM, Matt Bennett wrote:
> > On 07/04/2016 11:12 PM, Steffen Klassert wrote:
> >> On Mon, Jul 04, 2016 at 03:52:50AM +0000, Matt Bennett wrote:
> >>> *Resending as plain text so the mailing list accepts it.. Sorry S=
teffen and Herbert*
> >>>
> >>> =E2=80=8BHi,
> >>>
> >>> During long run testing of an ipsec tunnel over a PPP link it was=
 found that occasionally traffic would stop flowing over the tunnel. Ev=
entually the traffic would start again, however using the command "ip r=
oute flush cache" causes traffic to start flowing  again immediately.

Do you need the ppp link to reproduce it? How often does that happen?
It would be good to find a minimal setup with that the bug is reproduci=
ble.
