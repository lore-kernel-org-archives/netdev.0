From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 0/4] Fix up remaining defconfigs with missing CONFIG_NET
Date: Wed, 24 Sep 2014 13:45:28 -0700
Message-ID: <20140924204528.GD27927@roeck-us.net>
References: <20140924.144908.34261036132770745.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:50273 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbaIXUpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 16:45:32 -0400
Received: by mail-pa0-f54.google.com with SMTP id fb1so9460617pad.13
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 13:45:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140924.144908.34261036132770745.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2014 at 02:49:08PM -0400, David Miller wrote:
> 
> This is on top of Michal Marek's series and the IA64 fixups which are
> already in Linus's tree.
> 
> I validated things two different ways:
> 
> 1) I scanned every arch config file, and if it mentioned CONFIG_INET or
>    CONFIG_UNIX, I made sure it had CONFIG_NET=y
> 
> 2) I scanned every arch config file, and if it did not have CONFIG_NET=y
>    I made sure it did not reference any networking config options.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Ah, I was missing Michal's series. Sorry for the noise.

Guenter
