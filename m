From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/2 net] ptp: fix error codes in ptp_clock_register()
Date: Mon, 10 Jul 2017 11:21:03 +0200
Message-ID: <20170710092103.vnanagwpimk43zoz@localhost.localdomain>
References: <20170710071137.ui2fhjkqzjqhkopz@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ganesh Goudar <ganeshgr@chelsio.com>,
        Atul Gupta <atul.gupta@chelsio.com>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:33024 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753759AbdGJJVI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 05:21:08 -0400
Content-Disposition: inline
In-Reply-To: <20170710071137.ui2fhjkqzjqhkopz@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 10, 2017 at 10:11:37AM +0300, Dan Carpenter wrote:
> The ptp_clock_register() function returns NULL when it's #ifdefed out
> because CONFIG_PTP_1588_CLOCK is disabled.  Otherwise, it's intended to
> return error pointers.  Unfortunately, there are a couple paths where we
> forget to set the error code.  It means that we could result in NULL
> pointer dereferences in the callers.
> 
> Fixes: d94ba80ebbea ("ptp: Added a brand new class driver for ptp clocks.")

This "Fixes" tag references the wrong commit.  Please correct it.

Thanks,
Richard
