From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch] Fix handling of overlength pathname in AF_UNIX sun_path
Date: Wed, 18 Apr 2012 20:44:03 +0100
Message-ID: <20120418204403.3eb7d994@pyramind.ukuu.org.uk>
References: <4F8D497F.8060601@gmail.com>
	<20120417105107.GA8614@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Kerrisk <mtk.manpages@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	linux-api@vger.kernel.org, yoshfuji@linux-ipv6.org,
	David Miller <davem@davemloft.net>,
	Jan Engelhardt <jengelh@medozas.de>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:51992 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753066Ab2DRTmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 15:42:00 -0400
In-Reply-To: <20120417105107.GA8614@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think its pointless.

Yes there may have been a case years ago to nul terminate but thats now
how 4BSD defined the API so that's how the world looks.

It helps nobody on the app side because they'll be defensively coding for
the existing API for another ten years for enterprise distros anyway.

Alan
