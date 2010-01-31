From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sky2:  receive dma mapping error handling
Date: Sun, 31 Jan 2010 23:25:04 +0100
Message-ID: <20100131222504.GB3317@del.dom.local>
References: <20100128090835.0d93e53a@nehalam>
 <4B61DB79.4080703@majjas.com>
 <20100128223447.GC3109@del.dom.local>
 <4B621316.8070308@majjas.com>
 <20100128225621.GD3109@del.dom.local>
 <4B6216B9.1010802@majjas.com>
 <20100128153643.0fca3c51@nehalam>
 <4B645EF4.4050701@majjas.com>
 <20100131003449.GA11935@del.dom.local>
 <4B650465.7010503@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:59567 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909Ab0AaWZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2010 17:25:11 -0500
Content-Disposition: inline
In-Reply-To: <4B650465.7010503@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 30, 2010 at 11:17:41PM -0500, Michael Breuer wrote:
> On 01/30/2010 07:34 PM, Jarek Poplawski wrote:
> >On Sat, Jan 30, 2010 at 11:31:48AM -0500, Michael Breuer wrote:
> >>Jan 29 17:13:11 mail kernel: sky2 eth0: rx error, status 0x6230010
> >>length 1518
> >>Jan 29 17:13:11 mail kernel: sky2 eth0: rx error, status 0x7f40010
> >>length 1518
> >These are length errors, but status shows more than 1518, e.g. 2036
> >here, unless I miss something. Please, don't use jumbo frames in your
> >network until we fully debug it for regular frames (Stephen admitted
> >sky2 jumbo might be broken).
> MTU was 1500 - not using jumbo frames as they don't work.

Do you mean no NIC in your network could have sent such frames?

Jarek P.
