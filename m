From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH net-2.6/stable] [XFRM] AUDIT: Fix flowlabel text format.
Date: Mon, 28 Apr 2008 09:09:12 +1000 (EST)
Message-ID: <Xine.LNX.4.64.0804280908470.1406@us.intercode.com.au>
References: <20080427.122418.32604330.yoshfuji@linux-ipv6.org>
 <20080426.202558.208247674.davem@davemloft.net> <20080427.125437.59237838.yoshfuji@linux-ipv6.org>
 <20080426.222512.134613395.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="927316971-323111180-1209337752=:1406"
Cc: =?iso-2022-jp?Q?YOSHIFUJI_Hideaki_=2F_=B5=C8=C6=A3=B1=D1=CC=C0?=
	<yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org,
	Paul Moore <paul.moore@hp.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from namei.org ([69.55.235.186]:51534 "EHLO us.intercode.com.au"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752400AbYD0XJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Apr 2008 19:09:28 -0400
In-Reply-To: <20080426.222512.134613395.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--927316971-323111180-1209337752=:1406
Content-Type: TEXT/PLAIN; charset=iso-2022-jp
Content-Transfer-Encoding: 8BIT

On Sat, 26 Apr 2008, David Miller wrote:

> From: YOSHIFUJI Hideaki / µ»∆£±—Ã¿ <yoshfuji@linux-ipv6.org>
> Date: Sun, 27 Apr 2008 12:54:37 +0900 (JST)
> 
> > In article <20080426.202558.208247674.davem@davemloft.net> (at Sat, 26 Apr 2008 20:25:58 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> > 
> > > What about the format is it fixing?
> > 
> > Sorry...
> 
> I now understand the problem with the new changelog message.
> 
> > > Also, can this possibly break existing audit log scanning
> > > tools and parsers?
> > 
> > James?
> > 
> > We could add "flowlabel", but it is possible to break something, too.
> > Anyway, because the log format did not make sense as audit log,
> > we need to fix it.
> > 
> > ---
> > [XFRM] AUDIT: Fix flowlabel text format ambibuity.
> > 
> > Flowlabel text format was not correct and thus ambiguous.
> > For example, 0x00123 or 0x01203 are formatted as 0x123.
> > This is not what audit tools want.
> > 
> > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Patch applied, James if you have some objections let me know,
> otherwise I'll toss this to -stable too.

Ok, cc'ing Paul Moore, who's maintining this now.


-- 
James Morris
<jmorris@namei.org>
--927316971-323111180-1209337752=:1406--
