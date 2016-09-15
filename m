From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 7/9] net: ethernet: ti: cpts: calc mult and shift from
 refclk freq
Date: Thu, 15 Sep 2016 15:49:26 +0200
Message-ID: <20160915134926.GA27352@localhost.localdomain>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-8-grygorii.strashko@ti.com>
 <20160914202618.GC12195@netboy>
 <20160915115814.GB24676@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, WingMan Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:36804 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752297AbcIONte (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 09:49:34 -0400
Content-Disposition: inline
In-Reply-To: <20160915115814.GB24676@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 15, 2016 at 01:58:15PM +0200, Richard Cochran wrote:
> Can the input clock be higher than 1 GHz?  If not, I suggest using
> clocks_calc_mult_shift() with maxsec=4 and a setting the watchdog also
> to 4*HZ.

On second thought, with the new 12% timer batching, using 4*HZ for 32
bits of 1 GHz is cutting it too close.  So just keep it like you had
it, with maxsec=mask/freq and timeout=maxsec/2, to stay on the safe
side.

Thanks,
Richard
