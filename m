From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] i386: optimize memset of 6 and 8 bytes
Date: Fri, 17 Aug 2007 18:57:00 -0700
Message-ID: <1187402220.2789.2.camel@laptopd505.fenrus.org>
References: <20070817165030.5455f761@freepuppy.rosehill.hemminger.net>
	 <1187401774.2789.0.camel@laptopd505.fenrus.org>
	 <20070817185452.5cbf60c4@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:49634 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbXHRCBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 22:01:07 -0400
In-Reply-To: <20070817185452.5cbf60c4@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 2007-08-17 at 18:54 -0700, Stephen Hemminger wrote:
> On Fri, 17 Aug 2007 18:49:34 -0700
> Arjan van de Ven <arjan@infradead.org> wrote:
> 
> > 
> > On Fri, 2007-08-17 at 16:50 -0700, Stephen Hemminger wrote:
> > > Tne network code does memset for 6 and 8 byte values, that can easily
> > > be optimized into simple assignments without string instructions.
> > 
> > 
> > so... question.
> > Why are we doing this by hand? Wouldn't gcc just generate this code in
> > the first place (when using __builtin_memset)? I very much suspect it
> > would (and if some version doesn't.... we really ought to get that
> > fixed)
> 
> i386 and x86_64 are not using __builtin_memset, as least from the
> code that I see generated.

.. maybe we should just fix it that way then?

-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

