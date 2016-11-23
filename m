From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH ethtool] ethtool: Fix the "advertise" parameter logic.
Date: Wed, 23 Nov 2016 10:00:14 -0500
Message-ID: <20161123150014.GB13179@tuxdriver.com>
References: <1479858947-25017-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43608 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935294AbcKWPPx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 10:15:53 -0500
Content-Disposition: inline
In-Reply-To: <1479858947-25017-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2016 at 06:55:47PM -0500, Michael Chan wrote:
> From: Michael Chan <mchan@broadcom.com>
> 
> The current code ignores the value of the advertise parameter.  For example,
> 
> ethtool -s ethx advertise 0x1000
> 
> The full_advertising_wanted parameter of 0x1000 is not passed to the kernel.
> The reason is that advertising_wanted is NULL in this case, and ethtool
> will think that the user has given no advertisement input and so it will
> proceed to pass all supported advertisement speeds to the kernel.
> 
> The older legacy ethtool with similar logic worked because
> advertising_wanted was an integer and could take on -1 and 0.  It would pass
> the full_advertising_wanted value if advertising_wanted == -1.
> 
> This fix is to pass all supported advertisement speeds only when both
> advertising_wanted == NULL && full_advertising_wanted == NULL.
> 
> Signed-off-by: Michael Chan <michael.chan@broadcom.com>

Thanks, Michael -- merging...

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
