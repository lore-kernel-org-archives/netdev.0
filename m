From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6 4/4]: ipt: convert jiffie values to USER_HZ when
 dumping
Date: Fri, 5 Nov 2004 16:57:52 -0800
Message-ID: <20041105165752.3dee2876.davem@davemloft.net>
References: <418ABA6C.8060402@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <418ABA6C.8060402@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


All 4 patches applied, thanks Patrick.

BTW, you don't need to split up changes like this with such high
granularity.  It's perfectly fine to lump these kinds of simple
changes together as "Convert to USER_HZ when dumping in TC action
modules".

If the transformation is sizable or of non-trivial complexity, then
yes splitting up the individual changes makes sense and makes it easier
for people to review and verify the patches.

Just a FYI. :-)
