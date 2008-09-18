From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Fri, 19 Sep 2008 00:04:23 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0809182349410.4742@wrl-59.cs.helsinki.fi>
References: <20080819213417.45133573@tux> <20080823111446.06a350a2@tux>
 <Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi> <20080824163843.33b4f890@tux>
 <Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi> <20080826141812.589848a0@tux>
 <Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi> <20080828184919.611dd578@tux>
 <Pine.LNX.4.64.0808291045430.7971@wrl-59.cs.helsinki.fi> <20080830035650.42be37d7@tux>
 <Pine.LNX.4.64.0808301000180.12388@wrl-59.cs.helsinki.fi> <20080907051718.58bf133d@tux>
 <Pine.LNX.4.64.0809071341310.8991@wrl-59.cs.helsinki.fi> <20080908172043.0d25a427@tux>
 <Pine.LNX.4.64.0809100942370.24708@wrl-59.cs.helsinki.fi> <20080911143006.2f516569@tux>
 <Pine.LNX.4.64.0809112140250.26799@wrl-59.cs.helsinki.fi> <20080913203117.2a55ea2c@tux>
 <Pine.LNX.4.64.0809140722460.17271@wrl-59.cs.helsinki.fi> <20080916112411.062fa615@tux>
 <Pine.LNX.4.64.0809161726250.1034@wrl-59.cs.helsinki.fi> <20080918173554.1f874238@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1183167713-1221770992=:4742"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43170 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752714AbYIRVEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 17:04:25 -0400
In-Reply-To: <20080918173554.1f874238@tux>
Content-ID: <Pine.LNX.4.64.0809182350130.4742@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1183167713-1221770992=:4742
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0809182350131.4742@wrl-59.cs.helsinki.fi>

On Thu, 18 Sep 2008, Dâniel Fraga wrote:

> On Wed, 17 Sep 2008 13:23:28 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > There were some other timer related complications in 2.6.25 but it's so 
> > long time ago that I hardly remember anything about those anymore (and 
> > I'm not an expert on those things anyway). And it's still very open issue 
> > how that would cause the problem you're seeing.
> 
> 	I opened a bug report to timer developers...
> let's see if they can help:
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=11588

Ok. Another potential candidate might be scheduler (my wording was sloppy 
when I used "timer related complications" while time related was my main 
intention)...

Anyway, if/when you succeed collecting some strace of the server 
processes, please let me know (though putting a full one available might 
not be wise thing like I said earlier). After I thought it a bit, it might 
be enough the start the strace with -p for all server processes of a 
service during a stall and then resolve it after some amount of waiting 
with nmap (and hope that strace doesn't resolve it by interfering 
something relevant :-), you will see that from the fact that it resolves 
without nmap then). That would probably reveal if the processes where 
waiting in accept() or not, and if not, where they were.

-- 
 i.
---696208474-1183167713-1221770992=:4742--
