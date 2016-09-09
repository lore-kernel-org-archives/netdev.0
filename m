From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH] macsec: fix input range of 'icvlen' parameter
Date: Fri, 9 Sep 2016 16:15:44 +0200
Message-ID: <20160909141544.GQ5252@orbyte.nwl.cc>
References: <b1f730436465e511edb56e4486299e4f3835599b.1473428548.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35013 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750992AbcIIOPq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Sep 2016 10:15:46 -0400
Content-Disposition: inline
In-Reply-To: <b1f730436465e511edb56e4486299e4f3835599b.1473428548.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 09, 2016 at 04:02:22PM +0200, Davide Caratti wrote:
> the maximum possible ICV length in a MACsec frame is 16 octects, not 32:
> fix get_icvlen() accordingly, so that a proper error message is displayed
> in case input 'icvlen' is greater than 16.
> 
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>

Acked-by: Phil Sutter <phil@nwl.cc>
