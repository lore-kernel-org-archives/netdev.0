From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net:phy:dp83640: Initialize PTP clocks at device init.
Date: Tue, 4 Feb 2014 09:04:29 +0100
Message-ID: <20140204080429.GB4447@netboy>
References: <1391438218-21994-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:38368 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691AbaBDIEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 03:04:34 -0500
Received: by mail-ea0-f173.google.com with SMTP id d10so4203348eaj.4
        for <netdev@vger.kernel.org>; Tue, 04 Feb 2014 00:04:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1391438218-21994-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 03, 2014 at 03:36:58PM +0100, Stefan S=F8rensen wrote:
> The trigger and events functionality can be useful even if packet
> timestamping is not used, but the required PTP clock is only enabled
> when packet timestamping is started. This patch moves the clock enabl=
e
> to when the interface is configured.

I looked in the code and in the docs, and I can't find any reason not
to enable the clock earlier.

Acked-by: Richard Cochran <richardcochran@gmail.com>
