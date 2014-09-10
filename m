From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: PTP_PEROUT_REQUEST and clock stepping
Date: Wed, 10 Sep 2014 19:26:20 +0200
Message-ID: <20140910172619.GB5944@localhost.localdomain>
References: <54107965.6040007@emlix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Daniel =?iso-8859-1?Q?Gl=F6ckner?= <dg@emlix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:41392 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453AbaIJR0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 13:26:24 -0400
Received: by mail-we0-f175.google.com with SMTP id w61so4090240wes.20
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 10:26:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <54107965.6040007@emlix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2014 at 06:16:37PM +0200, Daniel Gl=F6ckner wrote:
> Hi,
> I was wondering how periodic output is supposed to behave if the cloc=
k
> is stepped from a time after ptp_perout_request.start to a time befor=
e
> ptp_perout_request.start.

I would say the result is undefined.

User space should first stop the periodic output, then reprogram the
clock, then restart the periodic output. Anything else makes no sense
at all.

Thanks,
Richard
