From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 1/3] ptp: Allow reassigning calibration pin
 function
Date: Thu, 26 Jun 2014 07:21:45 +0200
Message-ID: <20140626052144.GB4537@netboy>
References: <1403699851-11178-1-git-send-email-stefan.sorensen@spectralink.com>
 <1403699851-11178-2-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:58818 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbaFZFV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 01:21:56 -0400
Received: by mail-wi0-f181.google.com with SMTP id n3so326841wiv.2
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 22:21:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1403699851-11178-2-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2014 at 02:37:29PM +0200, Stefan S=F8rensen wrote:
> The ptp pin function programming does not allow calibration pin to ch=
ange
> function. This is problematic on hardware that uses the default calib=
ration
> pin for other purposes.
>=20
> Removing this limitation does not impact calibration if userspace doe=
s not
> reprogram the calibration pin.

Reassigning the calibration function never makes sense, because it is
only used in the driver probe method.

Clobbering the calibration pin with another function only makes sense
if the hardware design has exactly one PHY.

Can you please add a check in the dp83640 verify method to enforce
these two constraints?

Thanks,
Richard
