From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net:phy:dp83640: Initialize PTP clocks at device init.
Date: Mon, 3 Feb 2014 17:33:32 +0100
Message-ID: <20140203163332.GA9935@netboy>
References: <1391438218-21994-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:34534 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbaBCQdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 11:33:38 -0500
Received: by mail-ea0-f180.google.com with SMTP id o10so3861291eaj.11
        for <netdev@vger.kernel.org>; Mon, 03 Feb 2014 08:33:37 -0800 (PST)
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

Hm, I vaguely recall that there might have been some reason not enable
the clock too early. (Maybe this was related to multiple PHYs?)

Quickly looking at the code once again, I can't see anything wrong with
this now, but I'll look at it again tomorrow.

Thanks,
Richard
