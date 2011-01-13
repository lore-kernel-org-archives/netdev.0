From: Chris Rankin <rankincj@yahoo.com>
Subject: RE: [E1000-devel] [e100] Page allocation failure warning(?) in 2.6.36.3
Date: Thu, 13 Jan 2011 01:00:35 -0800 (PST)
Message-ID: <895344.13845.qm@web121707.mail.ne1.yahoo.com>
References: <1294894536.3335.510.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: JesseBrandeburg <jesse.brandeburg@intel.com>,
	David Miller <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Tushar NDave <tushar.n.dave@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeffrey TKirsher <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web121707.mail.ne1.yahoo.com ([98.138.90.128]:40388 "HELO
	web121707.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932429Ab1AMJAh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jan 2011 04:00:37 -0500
In-Reply-To: <1294894536.3335.510.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--- On Thu, 13/1/11, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Problem is e100 allocates an order-6 page in DMA zone
> (a 256 KB contigous area of ram)
> 
> This contigous area of ram is not available but just after
> booting...

I suspected as much. Fortunately, this machine has no function apart from routing and can happily left untouched for extended periods of time.

> On such small router, I doubt you need more than 64 slots
> in TX ring buffer.

But what would the effect of that change be to the interfaces' performance, please?

Cheers,
Chris


      
