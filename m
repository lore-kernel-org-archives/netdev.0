From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Thu, 18 Sep 2008 17:35:54 -0300
Message-ID: <20080918173554.1f874238@tux>
References: <20080819213417.45133573@tux>
	<20080822.143709.65615512.davem@davemloft.net>
	<20080823111446.06a350a2@tux>
	<Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
	<20080824163843.33b4f890@tux>
	<Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
	<20080826141812.589848a0@tux>
	<Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
	<20080828184919.611dd578@tux>
	<Pine.LNX.4.64.0808291045430.7971@wrl-59.cs.helsinki.fi>
	<20080830035650.42be37d7@tux>
	<Pine.LNX.4.64.0808301000180.12388@wrl-59.cs.helsinki.fi>
	<20080907051718.58bf133d@tux>
	<Pine.LNX.4.64.0809071341310.8991@wrl-59.cs.helsinki.fi>
	<20080908172043.0d25a427@tux>
	<Pine.LNX.4.64.0809100942370.24708@wrl-59.cs.helsinki.fi>
	<20080911143006.2f516569@tux>
	<Pine.LNX.4.64.0809112140250.26799@wrl-59.cs.helsinki.fi>
	<20080913203117.2a55ea2c@tux>
	<Pine.LNX.4.64.0809140722460.17271@wrl-59.cs.helsinki.fi>
	<20080916112411.062fa615@tux>
	<Pine.LNX.4.64.0809161726250.1034@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:23934 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755065AbYIRUgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 16:36:05 -0400
Received: by an-out-0708.google.com with SMTP id d40so6467and.103
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2008 13:36:02 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0809161726250.1034@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Sep 2008 13:23:28 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> There were some other timer related complications in 2.6.25 but it's =
so=20
> long time ago that I hardly remember anything about those anymore (an=
d=20
> I'm not an expert on those things anyway). And it's still very open i=
ssue=20
> how that would cause the problem you're seeing.

	I opened a bug report to timer developers...
let's see if they can help:

http://bugzilla.kernel.org/show_bug.cgi?id=3D11588

--=20
