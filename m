From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: PTP_PEROUT_REQUEST and clock stepping
Date: Fri, 12 Sep 2014 08:24:49 +0200
Message-ID: <CABkLOboeo_+37rE84gPTEKnmXD+599fRtnBZSR465y9aZeOdrw@mail.gmail.com>
References: <54107965.6040007@emlix.com>
	<20140910172619.GB5944@localhost.localdomain>
	<20140911095245.GA5823@emlix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?Q?Daniel_Gl=C3=B6ckner?= <dg@emlix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:39669 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbaILGYu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 02:24:50 -0400
Received: by mail-qa0-f42.google.com with SMTP id j7so268906qaq.1
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 23:24:49 -0700 (PDT)
In-Reply-To: <20140911095245.GA5823@emlix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 11, 2014 at 11:52 AM, Daniel Gl=C3=B6ckner <dg@emlix.com> w=
rote:
> Only a small fraction of people
> using periodic outputs will want to schedule the start of the signal =
at
> a specific time in the future and only a fraction of those will use a
> .period value that is so small that they can't use a timer to configu=
re
> the periodic output within .period/2 before the desired start time.

Ok, I got it now. So you are suggesting to change the behavior of
PTP_PEROUT_REQUEST, aren't you? And break existing applications?
Christian
