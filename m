From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net:phy:dp83640: Do not hardcode timestamping event edge
Date: Mon, 3 Feb 2014 17:20:44 +0100
Message-ID: <20140203162043.GC6011@netboy>
References: <1391438210-21941-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:56575 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbaBCQUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 11:20:49 -0500
Received: by mail-ea0-f175.google.com with SMTP id z10so3843429ead.34
        for <netdev@vger.kernel.org>; Mon, 03 Feb 2014 08:20:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1391438210-21941-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 03, 2014 at 03:36:50PM +0100, Stefan S=F8rensen wrote:
> Currently the external timestamping code it hardcoded to use
> the rising edge even though the hardware has configurable event
> edge detection. This patch change the code to use falling edge
> detection if PTP_FALLING_EDGE is set in the user supplied flags.
>=20
> Signed-off-by: Stefan S=F8rensen <stefan.sorensen@spectralink.com>
> ---

Acked-by: Richard Cochran <richardcochran@gmail.com>
