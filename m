From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH ethtool 0/3] ethtool: Add support for new high speed adv.
Date: Mon, 22 Aug 2016 15:32:19 -0400
Message-ID: <20160822193218.GD2628@tuxdriver.com>
References: <1471845039-28718-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vidya@cumulusnetworks.com
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37265 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753952AbcHVTpR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 15:45:17 -0400
Content-Disposition: inline
In-Reply-To: <1471845039-28718-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2016 at 08:50:36AM +0300, Yuval Mintz wrote:
> This allows ethtool to utilize the link capabilities/adv./lp bitmasks
> to show and set the additional 25g, 50g and 100g link speeds.
> 
> Patches #1 & #2 are based on Vidya Sagar Ravipati's patches
> [with the only addition being the addition of the 50g SR2 mode],
> while patch #3 updates the man-page with the additional modes.
> 
> Can't claim to have tried all modes, although I did play with both
> 25g KR and 50g KR2 which seemed to be working fine.
> 
> Yuval Mintz (3):
>   ethtool: Copy high-speed bits from ethtool.h
>   ethtool: Add support 25g, 50g and 100g speeds
>   ethtool: Document new ethtool advertise speeds
> 
>  ethtool-copy.h | 12 +++++++++++-
>  ethtool.8.in   | 10 ++++++++++
>  ethtool.c      | 30 ++++++++++++++++++++++++++++++
>  3 files changed, 51 insertions(+), 1 deletion(-)

It looks like Vidya wasn't completely in-sync with you on this! But,
I like that you included the later bits for ethtool-copy.h and that
you added man page updates.

Could you and Vidya get together and post a unified patchset,
please? Or if Vidya posts the updates I requested, I can simply take
your (i.e. Yuval's) patch 3/3 on top of that.

John
-- 
John W. Linville		Someday the world will need a hero, yand you
linville@tuxdriver.com			might be all we have.  Be ready.
