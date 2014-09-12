From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: PTP_PEROUT_REQUEST and clock stepping
Date: Fri, 12 Sep 2014 08:17:45 +0200
Message-ID: <CABkLObpyxgxsPZDEyf=Wr+Cfy5Kav9KmxkKOtWXP_4S5Jh8+Fg@mail.gmail.com>
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
Received: from mail-qc0-f182.google.com ([209.85.216.182]:32771 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268AbaILGRq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 02:17:46 -0400
Received: by mail-qc0-f182.google.com with SMTP id x13so290694qcv.13
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 23:17:45 -0700 (PDT)
In-Reply-To: <20140911095245.GA5823@emlix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

On Thu, Sep 11, 2014 at 11:52 AM, Daniel Gl=C3=B6ckner <dg@emlix.com> w=
rote:
> On Wed, Sep 10, 2014 at 07:26:20PM +0200, Richard Cochran wrote:
>> On Wed, Sep 10, 2014 at 06:16:37PM +0200, Daniel Gl=C3=B6ckner wrote=
:
>> > I was wondering how periodic output is supposed to behave if the c=
lock
>> > is stepped from a time after ptp_perout_request.start to a time be=
fore
>> > ptp_perout_request.start.
>>
>> I would say the result is undefined.
>>
>> User space should first stop the periodic output, then reprogram the
>> clock, then restart the periodic output. Anything else makes no sens=
e
>> at all.
>
> But then the PTP demon has to be responsible for configuring the peri=
odic
> outputs as well.

I guess yes, but is that a problem?

> IMHO there is no use for a .start value > .period. It is good for def=
ining

There is, for the small fraction of people you note below. But you are
talking about PTP_PEROUT_REQUEST here, right?

> the phase of the periodic output but is just annoying if you want to =
have
> the periodic output running all the time.

How about PTP_ENABLE_PPS? Is this the ptp clock feature you are looking=
 for?

> Only a small fraction of people
> using periodic outputs will want to schedule the start of the signal =
at
> a specific time in the future and only a fraction of those will use a
> .period value that is so small that they can't use a timer to configu=
re
> the periodic output within .period/2 before the desired start time.

What timer?

Regards,
Christian
