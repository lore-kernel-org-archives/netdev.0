From: Edward Cree <ecree@solarflare.com>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by
 default
Date: Wed, 24 Feb 2016 17:30:59 +0000
Message-ID: <56CDE8D3.5000409@solarflare.com>
References: <CALx6S34Pt++Kg=cp+v+gGFQGEDy=eNHtFvtBwd1z-1d2ixOn7Q@mail.gmail.com>
 <56CC94D9.4030308@hpe.com> <56CC9914.5010506@solarflare.com>
 <20160223.130826.608797488173024832.davem@davemloft.net>
 <56CCBF22.6020904@solarflare.com>
 <CALx6S35_vaAp9SWmh_SrLteZJxZ0eH1i+tp=2K7x3Que7h8wsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hpe.com>,
	Jesse Gross <jesse@kernel.org>,
	Alex Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:27931 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756439AbcBXRbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 12:31:07 -0500
In-Reply-To: <CALx6S35_vaAp9SWmh_SrLteZJxZ0eH1i+tp=2K7x3Que7h8wsQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/02/16 00:53, Tom Herbert wrote:
> That's an interesting idea. This should work in IPv6 now and nearly
> all encapsulation protocols (GRE w/ csum doesn't work this way for
> instance)
You mean GRE with sequence numbers?  csum should be fine, it'sjust the
usual LCO setup (i.e. only depends on headers).

-Ed
