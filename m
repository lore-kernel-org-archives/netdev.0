From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.0.23 WARNING: at net/ipv4/tcp_input.c:3375
 tcp_ack+0x1d62/0x2030()
Date: Mon, 19 Mar 2012 10:13:40 -0700
Message-ID: <1332177220.9397.33.camel@edumazet-glaptop>
References: <4F66EA0B.1080705@profihost.ag>
	 <20120319161534.GC24487@kroah.com>  <20120319161604.GA2972@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	stable@vger.kernel.org, Linux Netdev List <netdev@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:39650 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161009Ab2CSRNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 13:13:42 -0400
In-Reply-To: <20120319161604.GA2972@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-03-19 at 09:16 -0700, Greg KH wrote:
> On Mon, Mar 19, 2012 at 09:15:34AM -0700, Greg KH wrote:
> > On Mon, Mar 19, 2012 at 09:10:51AM +0100, Stefan Priebe - Profihost AG wrote:
> > > Hi list,
> > > 
> > > today i've seen the following error / backtrace several times on a
> > > machine running vanilla stable 3.0.23.
> > 
> > Can you try 3.0.24?
> 
> That would be 3.0.25, sorry about that.

Yes, this includes the following fixes :

Neal Cardwell (3):
      tcp: fix false reordering signal in tcp_shifted_skb
      tcp: don't fragment SACKed skbs in tcp_mark_head_lost()
      tcp: fix tcp_shift_skb_data() to not shift SACKed data below snd_una
