From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [Linuxptp-devel] RFC [PATCH 2/3] PTP: use flags to request HW
 features
Date: Thu, 31 Oct 2013 23:34:19 -0200
Message-ID: <20131101013419.GH4202@plex.lan>
References: <1383159637-8165-1-git-send-email-fbl@redhat.com>
 <1383159637-8165-3-git-send-email-fbl@redhat.com>
 <20131030214841.GZ13373@plex.lan>
 <20131031071256.GB5226@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxptp-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10459 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752412Ab3KABdl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Oct 2013 21:33:41 -0400
Content-Disposition: inline
In-Reply-To: <20131031071256.GB5226@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 31, 2013 at 08:12:58AM +0100, Richard Cochran wrote:
> On Wed, Oct 30, 2013 at 07:48:41PM -0200, Flavio Leitner wrote:
> > On Wed, Oct 30, 2013 at 05:00:36PM -0200, Flavio Leitner wrote:
> > > Currently the user space can't tell which delay mechanism
> > > (E2E/P2P) or transport is needed in the ioctl(). Therefore,
> > > PTP silently fails when the hardware doesn't support a
> > > certain delay mechanism or transport.
> 
> [ For netdev readers, the text below repeats what I posted to the
>   linuxptp-devel list. ]

I am reconsidering about extending ethtool instead, so I'd like to
drop these patches for now.
Thanks Richard and Jacob for the contributions,
fbl
