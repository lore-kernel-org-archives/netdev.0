From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Fri, 24 Feb 2012 15:36:16 -0500 (EST)
Message-ID: <20120224.153616.117399887784547022.davem@davemloft.net>
References: <1329753455-1106-1-git-send-email-javier@collabora.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, lennart@poettering.net,
	kay.sievers@vrfy.org, alban.crequy@collabora.co.uk,
	bart.cerneels@collabora.co.uk, rodrigo.moya@collabora.co.uk,
	sjoerd.simons@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: javier@collabora.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329753455-1106-1-git-send-email-javier@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


My first impression is that I'm amazed at how much complicated new
code you have to add to support groups of receivers of AF_UNIX
messages.

I can't see how this is better than doing multicast over ipv4 using
UDP or something like that, code which we have already and has been
tested for decades.

I really don't want to apply this stuff, it looks bloated,
complicated, and there is another avenue for doing what you want to
do.

Applications have to change to support the new multicast facilities,
so they can equally be changed to use a real transport that already
supports multicasting.
