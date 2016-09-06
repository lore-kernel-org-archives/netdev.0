From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: Don't delete routes in different VRFs
Date: Tue, 06 Sep 2016 13:56:41 -0700 (PDT)
Message-ID: <20160906.135641.2126464263336660217.davem@davemloft.net>
References: <20160902052607.9303-1-mark.tomlinson@alliedtelesis.co.nz>
        <20160904222020.11604-1-mark.tomlinson@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com
To: mark.tomlinson@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53944 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935265AbcIFU5I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 16:57:08 -0400
In-Reply-To: <20160904222020.11604-1-mark.tomlinson@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>
Date: Mon,  5 Sep 2016 10:20:20 +1200

> When deleting an IP address from an interface, there is a clean-up of
> routes which refer to this local address. However, there was no check to
> see that the VRF matched. This meant that deletion wasn't confined to
> the VRF it should have been.
> 
> To solve this, a new field has been added to fib_info to hold a table
> id. When removing fib entries corresponding to a local ip address, this
> table id is also used in the comparison.
> 
> The table id is populated when the fib_info is created. This was already
> done in some places, but not in ip_rt_ioctl(). This has now been fixed.
> 
> Fixes: 021dd3b8a142 ("net: Add routes to the table associated with the device")
> Acked-by: David Ahern <dsa@cumulusnetworks.com>
> Tested-by: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>

Applied and queued up for -stable, thanks.
