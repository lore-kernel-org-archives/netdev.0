From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: race in skb_splice_bits?
Date: Tue, 27 May 2008 15:56:38 +0400
Message-ID: <20080527115638.GB30353@2ka.mipt.ru>
References: <200805270325.24323.opurdila@ixiacom.com> <20080527110144.GA15141@2ka.mipt.ru> <20080527110840.GH28241@solarflare.com> <20080527115206.GA30353@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Octavian Purdila <opurdila@ixiacom.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:44448 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755158AbYE0L4v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 07:56:51 -0400
Content-Disposition: inline
In-Reply-To: <20080527115206.GA30353@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 27, 2008 at 03:52:06PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> On Tue, May 27, 2008 at 12:08:41PM +0100, Ben Hutchings (bhutchings@solarflare.com) wrote:
> > However, from Octavian's later mail it seems we can't let the skb go away
> > at all.  So some wider changes seem to be required.
> 
> Yes, I misread the original message.
> 
> Octavian, could you please decode where bug occured via gdb:
> gdb
> $ l *(skb_splice_bits+0x130)

It is lock_sock()?

And also please show what
tcp_read_sock+0x108
tcp_read_sock+0x138

are. And do you have a test case for that?

-- 
	Evgeniy Polyakov
