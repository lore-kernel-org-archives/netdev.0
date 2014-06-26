From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 1/2] ptp: Classify ptp over ip over vlan packets
Date: Thu, 26 Jun 2014 07:32:56 +0200
Message-ID: <20140626053256.GC4537@netboy>
References: <1403699148-10640-1-git-send-email-stefan.sorensen@spectralink.com>
 <1403699148-10640-2-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:56850 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483AbaFZFdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 01:33:09 -0400
Received: by mail-wg0-f52.google.com with SMTP id b13so3048613wgh.11
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 22:33:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1403699148-10640-2-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2014 at 02:25:47PM +0200, Stefan S=F8rensen wrote:
> This extends the ptp bpf to also match ptp over ip over vlan packets.=
 The ptp
> classes are changed to orthogonal bitfields representing version, tra=
nsport
> and vlan values to simplify matching.
>=20
> Signed-off-by: Stefan S=F8rensen <stefan.sorensen@spectralink.com>
> ---
>  drivers/net/ethernet/ti/cpts.c | 24 ++++++++--------
>  drivers/net/phy/dp83640.c      | 46 ++++++++++++++----------------
>  include/linux/ptp_classify.h   |  5 ++--
>  net/core/ptp_classifier.c      | 64 ++++++++++++++++++++++++++++++++=
++++++----

The change in this file

>  net/core/timestamping.c        | 57 +++++++++++++-------------------=
-----

has nothing to do with the vlan stuff. Can you please put that into a
separate patch?

Thanks,
Richard
