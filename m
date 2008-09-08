From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Mon, 8 Sep 2008 13:27:43 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0809071341310.8991@wrl-59.cs.helsinki.fi>
References: <20080819213417.45133573@tux> <Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
 <20080822183224.2d52f16c@tux> <20080822.143709.65615512.davem@davemloft.net>
 <20080823111446.06a350a2@tux> <Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
 <20080824163843.33b4f890@tux> <Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
 <20080826141812.589848a0@tux> <Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
 <20080828184919.611dd578@tux> <Pine.LNX.4.64.0808291045430.7971@wrl-59.cs.helsinki.fi>
 <20080830035650.42be37d7@tux> <Pine.LNX.4.64.0808301000180.12388@wrl-59.cs.helsinki.fi>
 <20080907051718.58bf133d@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-129813521-1220784120=:8991"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60823 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002AbYIHK1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 06:27:46 -0400
In-Reply-To: <20080907051718.58bf133d@tux>
Content-ID: <Pine.LNX.4.64.0809081257380.1034@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-129813521-1220784120=:8991
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0809081257381.1034@wrl-59.cs.helsinki.fi>

On Sun, 7 Sep 2008, Dâniel Fraga wrote:

> On Mon, 1 Sep 2008 10:11:25 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > That's one option. If you do that, you could try catching two flies at the 
> > same time by selecting something else than tickless.
> 
> 	Hi Ilpo. I *think* I discovered the source of the problem. It's
> not related to gcc, neither dynticks.
> 
> 	I'm almost sure it's related to *High Resolution Timer*. I
> simply disabled this option and the problems disappeared.
> 
> 	I'd like to ask you if it does make sense, based on the
> problem we've being discussing over these weeks. What's your opinion?

It could well be possible, accept seems to call schedule_timeout if 
nothing is immediately available (but I don't know well enough what 
end up being hrtimer'ed when you enable them and what will not)... 
Anyway, how long did you test for that to confirm it?

Does this explain the 2.6.24->2.6.25 change in behavior as well (ie., 
did they got enabled there)?

-- 
 i.
---696208474-129813521-1220784120=:8991--
