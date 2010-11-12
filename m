From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 4/10] Fix leaking of kernel heap addresses in net/
Date: Fri, 12 Nov 2010 22:18:50 +0200
Message-ID: <20101112201850.GA5625@core2.telecom.by>
References: <2129857903-1289528127-cardhu_decombobulator_blackberry.rim.net-1506931048-@bda083.bisx.prod.on.blackberry>
 <20101111.182939.258124014.davem@davemloft.net>
 <1289529269.3090.207.camel@Dan>
 <1289546610.17691.1770.camel@edumazet-laptop>
 <20101112083315.096dfaa3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:52945 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406Ab0KLUS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 15:18:56 -0500
Received: by eye27 with SMTP id 27so2169826eye.19
        for <netdev@vger.kernel.org>; Fri, 12 Nov 2010 12:18:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20101112083315.096dfaa3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 12, 2010 at 08:33:15AM -0800, Stephen Hemminger wrote:
> Also, the whole idea needs to be under a config option, so only
> the paranoid idiots turn it on.

Would be fun if something will break because ffff8800bcd498c0
will become something else. :-)
