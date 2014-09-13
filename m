From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: PTP_PEROUT_REQUEST and clock stepping
Date: Sat, 13 Sep 2014 11:19:15 +0200
Message-ID: <20140913091915.GB4581@netboy>
References: <54107965.6040007@emlix.com>
 <20140910172619.GB5944@localhost.localdomain>
 <20140911095245.GA5823@emlix.com>
 <CABkLOboeo_+37rE84gPTEKnmXD+599fRtnBZSR465y9aZeOdrw@mail.gmail.com>
 <20140912063310.GA6198@netboy>
 <5412DBB0.9010008@emlix.com>
 <20140912144025.GA20712@netboy>
 <54130F01.3080404@emlix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christian Riesch <christian.riesch@omicron.at>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel =?iso-8859-1?Q?Gl=F6ckner?= <dg@emlix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:48649 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877AbaIMJTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 05:19:22 -0400
Received: by mail-wg0-f48.google.com with SMTP id m15so1712224wgh.19
        for <netdev@vger.kernel.org>; Sat, 13 Sep 2014 02:19:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <54130F01.3080404@emlix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 12, 2014 at 05:19:29PM +0200, Daniel Gl=F6ckner wrote:
> 0. I'm assuming here that new_time >=3D start

=46eel free to submit a patch, but please be sure to handle the case
where (new_time < start) as well. In addition, it can happen that
abs(new_time-start) < X, where X is the time it takes to reprogramm
the signal.

Thanks,
Richard
