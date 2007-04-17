From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-2.6.22 1/3] [TCP]: Sed magic converts func(sk, tp,
 ...) -> func(sk, ...)
Date: Tue, 17 Apr 2007 10:45:47 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0704171033590.20010@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0704161758020.28337@kivilampi-30.cs.helsinki.fi>
 <462396F5.9030907@trash.net> <Pine.LNX.4.64.0704161913400.28337@kivilampi-30.cs.helsinki.fi>
 <20070416.171604.26532491.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-954150138-1176795464=:20010"
Cc: kaber@trash.net, hch@infradead.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36109 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861AbXDQHpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 03:45:50 -0400
In-Reply-To: <20070416.171604.26532491.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0704171037540.20010@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-954150138-1176795464=:20010
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0704171037541.20010@kivilampi-30.cs.helsinki.fi>

On Mon, 16 Apr 2007, David Miller wrote:
> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 16 Apr 2007 19:19:02 +0300 (EEST)
> 
> > [PATCH] [TCP]: Sed magic converts func(sk, tp, ...) -> func(sk, ...)
> 
> I was trying to spread out the net-2.6.22 tree from the tcp-2.6
> one so that we could do the experimental TCP stuff in the tcp-2.6
> tree and leave other networking changes for net-2.6.22
> 
> Putting in TCP cleanups which touch a lot of code into net-2.6.22
> defeats that effort because now there will be all kinds of rejects and
> merge errors people will have to deal with if they clone a net-2.6.22
> tree then pull in tcp-2.6 to do some TCP hacking which is valid.
> 
> I suppose we can live with that, and just tell people to just pull
> tcp-2.6 into a fresh linux-2.6 tree straight, but it's going to make
> rebasing difficult for me as well.
>
> net-2.6.22 is already approaching 350 patches, it's a monster and
> the merge conflicts and rebasing pain are really getting hard to
> deal with.

I fully understand your concerns (I had already though that you might 
rather want to put this kind of thing to tcp-2.6)... It will be almost 
trivial to base it to tcp-2.6 because it's, well, (mostly) automated.
I'll try to get that done today so you'll have less worries... :-)


-- 
 i.
---696243703-954150138-1176795464=:20010--
