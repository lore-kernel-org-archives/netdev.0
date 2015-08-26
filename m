From: Phil Sutter <phil@nwl.cc>
Subject: Re: [[net-next] lo uses DEPRECATED zero tx_queue_len - convert
 driver to use IFF_NO_QUEUE instead
Date: Wed, 26 Aug 2015 11:34:26 +0200
Message-ID: <20150826093426.GA20760@orbit.nwl.cc>
References: <CAMuHMdX6O3_wtWagwAKgVd=aifXjVd5rw8VczF18VS9+Mm30oQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:49504 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753974AbbHZJe3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2015 05:34:29 -0400
Content-Disposition: inline
In-Reply-To: <CAMuHMdX6O3_wtWagwAKgVd=aifXjVd5rw8VczF18VS9+Mm30oQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2015 at 01:16:41PM +0200, Geert Uytterhoeven wrote:
> I don't know if this was reported before (I'm not subscribed to netdev), but
> Google couldn't find it:
> 
> lo uses DEPRECATED zero tx_queue_len - convert driver to use
> IFF_NO_QUEUE instead

This is fixed by commit e65db2b ("net: loopback: convert to using
IFF_NO_QUEUE"), part of a bigger series converting drivers (see here:
http://lists.openwall.net/netdev/2015/08/18/52).

Cheers, Phil
