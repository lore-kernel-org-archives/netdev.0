From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: setsockopt()
Date: Mon, 7 Jul 2008 20:33:10 -0700
Message-ID: <1e41a3230807072033n2f5519e4m42003e191b44cefe@mail.gmail.com>
References: <48725DFE.6000504@citi.umich.edu> <20080707142408.43aa2a2e@extreme>
	 <48728B09.1050801@citi.umich.edu> <48729DAD.8010400@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:36596 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756125AbYGHDdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 23:33:13 -0400
Received: by an-out-0708.google.com with SMTP id d40so474964and.103
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2008 20:33:10 -0700 (PDT)
In-Reply-To: <48729DAD.8010400@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 7, 2008 at 3:50 PM, Rick Jones <rick.jones2@hp.com> wrote:
> I'm still a triffle puzzled/concerned/confused by the extent to which
> autotuning will allow the receive window to grow, again based on some
> netperf experience thusfar, and patient explanations provided here and
> elsewhere, it seems as though autotuning will let things get to 2x what it
> thinks the sender's cwnd happens to be.  So far under netperf testing that
> seems to be the case, and 99 times out of ten my netperf tests will have the
> window grow to the max.


Rick,

I thought this was covered pretty thoroughly back in April.  The
behavior you're seeing is 100% expected, and not likely to change
unless Jerry Chu gets his local queued data measurement patch working.
 I'm not sure what ultimately happened there, but it was a cool idea
and I hope he has time to polish it up.  It's definitely tricky to get
right.

Jerry's optimization is a sender-side change.  The fact that the
receiver announces enough window is almost certainly the right thing
for it to do, and (I hope) this will not change.

If you're still curious:
http://www.psc.edu/networking/ftp/papers/autotune_sigcomm98.ps
http://www.lanl.gov/radiant/pubs/drs/lacsi2001.pdf
http://staff.psc.edu/jheffner/papers/senior_thesis.pdf

  -John
