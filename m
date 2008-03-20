From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [2.6.25-rc5-mm1] regression: cannot run Postfix sendmail command as non-root
Date: Thu, 20 Mar 2008 15:38:52 +0100
Message-ID: <200803201538.53377.rjw@sisk.pl>
References: <47D98510.60801@imap.cc> <47E25DF5.3090107@openvz.org> <939d53060803200648s422969b5m429fa444bdcacc35@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Pavel Emelyanov" <xemul@openvz.org>,
	"David Miller" <davem@davemloft.net>, akpm@linux-foundation.org,
	tilman@imap.cc, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org,
	dlezcano@fr.ibm.com, ebiederm@xmission.com
To: "Benjamin Thery" <ben.thery@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:35472 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756236AbYCTOjz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2008 10:39:55 -0400
In-Reply-To: <939d53060803200648s422969b5m429fa444bdcacc35@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, 20 of March 2008, Benjamin Thery wrote:
> On Thu, Mar 20, 2008 at 1:52 PM, Pavel Emelyanov <xemul@openvz.org> wrote:
> >
> > Rafael J. Wysocki wrote:
> >  > On Thursday, 20 of March 2008, Benjamin Thery wrote:
> >  >> On Wed, Mar 19, 2008 at 11:49 PM, David Miller <davem@davemloft.net> wrote:
> >  >>> From: Andrew Morton <akpm@linux-foundation.org>
> >  >>>  Date: Wed, 19 Mar 2008 14:16:08 -0700
> >  >>>
> >  >>>
> >  >>>  > Although this is advertised as a 2.6.25-rc5-mm1 problem, I assume the
> >  >>>  > regression is also in mainline? 2.6.25-rc6?
> >  >>>
> >  >>>  It is in 2.6.25-rc6, correct.
> >  >>>
> >  >>>  If Pavel or someone else doesn't produce a good fix soon
> >  >>>  I'll revert the guilty change as this bug is worse than
> >  >>>  the problem that changeset fixes.
> >  >> Andre Noll sent a patch to LKML, acked by Pavel:
> >  >>
> >  >> "Fix permissions of /proc/net"
> >  >> http://thread.gmane.org/gmane.linux.kernel/655148
> >  >
> >  > Have you tested that patch?
> >
> >  I did - works OK, that's why I Acked it.
> 
> Also tested here. It fixes the regression.

OK, thanks.

Rafael
