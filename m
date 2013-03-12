From: Dave Jones <davej@redhat.com>
Subject: Re: e1000e failed to check map error
Date: Tue, 12 Mar 2013 14:51:01 -0400
Message-ID: <20130312185101.GA13662@redhat.com>
References: <20130301053007.GA14474@redhat.com>
 <804857E1F29AAC47BF68C404FC60A1844D022AE1@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44451 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932302Ab3CLSvR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Mar 2013 14:51:17 -0400
Content-Disposition: inline
In-Reply-To: <804857E1F29AAC47BF68C404FC60A1844D022AE1@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 01, 2013 at 05:13:29PM +0000, Allan, Bruce W wrote:
 > > -----Original Message-----
 > > From: netdev-owner@vger.kernel.org [mailto:netdev-
 > > owner@vger.kernel.org] On Behalf Of Dave Jones
 > > Sent: Thursday, February 28, 2013 9:30 PM
 > > To: netdev@vger.kernel.org
 > > Subject: e1000e failed to check map error
 > > 
 > > Linus' current tree shows this shortly after boot for me..
 > > 
 > > WARNING: at lib/dma-debug.c:933 check_unmap+0x407/0x8a0()
 > 
 > Thanks for the report Dave.  I'll look into it.
 > 
 > Bruce.

fwiw, I see this also on 3.8.x, albeit with a different size..

 e1000e 0000:05:00.0: DMA-API: device driver failed to check map error[device address=0x0000000007130000] [size=24 bytes] [mapped as page]

Same backtrace though.

	Dave
