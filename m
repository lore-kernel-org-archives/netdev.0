From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: PTP: PHY timestamping when MAC is PTP capable
Date: Mon, 28 Aug 2017 05:33:31 -0700
Message-ID: <20170828123331.sv52oawme6hfpdy2@localhost>
References: <1503909582.2455.2.camel@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?iso-8859-1?B?U/hyZW5zZW4s?= Stefan
        <Stefan.Sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:33676 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750866AbdH1Mdf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 08:33:35 -0400
Received: by mail-pg0-f41.google.com with SMTP id t3so1129456pgt.0
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 05:33:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1503909582.2455.2.camel@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 08:39:44AM +0000, Sørensen, Stefan wrote:
> I have run into a problem with packet timestamping on a platform (cpsw
> + dp83640) where both the PHY and the MAC is PTP capable and I need
> the PHY to perform the timestamping. In the current code,
> SIOCGHWTSTAMP is passed to the MAC driver and only if it does not
> support PTP itself will it pass it on to the PHY driver.
> 
> I see two ways to fix this:

Just disable CONFIG_CPTS and patch cpsw.c to pass SIOC[GS]HWTSTAMP.

I don't see any reasonable way to make this sort of thing configurable
at run time.

Thanks,
Richard
