From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: XTP for 2.6.25
Date: Sat, 26 Apr 2008 00:06:58 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804252353550.9132@wrl-59.cs.helsinki.fi>
References: <18b669d80804250151h516788cdqc7931a7ab5a195de@mail.gmail.com>
 <20080425.015508.254917794.davem@davemloft.net>
 <Pine.LNX.4.64.0804251558550.1888@wrl-59.cs.helsinki.fi>
 <20080425.131255.95495287.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-213856561-1209157618=:9132"
Cc: shigeonx@gmail.com, andi@firstfloor.org,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58255 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758628AbYDYVHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 17:07:05 -0400
In-Reply-To: <20080425.131255.95495287.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-213856561-1209157618=:9132
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 25 Apr 2008, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Fri, 25 Apr 2008 16:05:51 +0300 (EEST)
> 
> > On Fri, 25 Apr 2008, David Miller wrote:
> > 
> > > From: "Shigeo N" <shigeonx@gmail.com>
> > > Date: Fri, 25 Apr 2008 17:51:49 +0900
> > > 
> > > > One host(sender) is 2.6.25, but the other(receiver) is 2.6.18.
> > > > I will evaluate again after I upgrade it to 2.6.25.
> > > 
> > > The bug fix isn't in 2.6.25 either.
> > 
> > Sure it is, or git is lying:
> > 
> > $ git-describe dd9e0dda66ba38a2ddd1405ac279894260dc5c36
> > v2.6.25-rc8-1190-gdd9e0dd
> 
> I just submitted the TCP reorder patch for 2.6.25-stable, it applied
> on top of a tree for which I did:
> 
> 	git checkout -b linux25 v2.6.25
> 
> so something is up :-)

Of course I was wrong :-), misintepreted git-describe's result as it 
cannot prove what I was trying to make it to prove (basically it was
reporting just the latest net-2.6 -> net-2.6.26 merge of yours, while 
that doesn't tell anything about entry of a commit to Linus' tree).

...Sorry about the noise.

-- 
 i.
---696208474-213856561-1209157618=:9132--
