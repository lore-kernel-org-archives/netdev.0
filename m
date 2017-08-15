From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 21/51] lib/libnetlink: Don't pass NULL parameter
 to memcpy()
Date: Tue, 15 Aug 2017 18:42:55 +0200
Message-ID: <20170815164255.GA10864@orbyte.nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
 <20170812120510.28750-22-phil@nwl.cc>
 <20170815081555.104dab6e@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:50477 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752421AbdHOQm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 12:42:56 -0400
Content-Disposition: inline
In-Reply-To: <20170815081555.104dab6e@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 15, 2017 at 08:15:55AM -0700, Stephen Hemminger wrote:
> On Sat, 12 Aug 2017 14:04:40 +0200
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > Both addattr_l() and rta_addattr_l() may be called with NULL data
> > pointer and 0 alen parameters. Avoid calling memcpy() in that case.
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> 
> What are you fixing. memcpy(dest, NULL, 0) should be harmless NOP

Yes, if that turns into a NOP this patch is not needed.

Thanks, Phil
