From: Dan Williams <dcbw@redhat.com>
Subject: Re: ne driver crashes when unloaded in 2.6.22.6
Date: Sun, 16 Sep 2007 17:14:38 -0400
Message-ID: <1189977278.30308.2.camel@xo-3E-67-34.localdomain>
References: <343200.37246.qm@web52908.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Rankin <rankincj@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47341 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752806AbXIPVQL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Sep 2007 17:16:11 -0400
In-Reply-To: <343200.37246.qm@web52908.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-09-15 at 21:27 +0100, Chris Rankin wrote:
> --- Dan Williams <dcbw@redhat.com> wrote:
> > On Wed, 2007-09-12 at 19:23 +0100, Chris Rankin wrote:
> > > Hmm, apparently not. The light on the card goes out though, so could this just be a lack of
> > driver
> > > support?
> > 
> > Likely, yes.
> 
> I've been trawling the Internet for 8390 specifications and have discovered that there is a
> "Carrier Sense Loss" flag on the "Transmit Status Register". However, there doesn't seem to be an
> explicit "media status" test. Would this more likely be part of the NE2000's functionality? I
> can't find any signs of MII support, but then the NE2000 is so heavily cloned that
> "NE2000-compatible" seems to have become more of a generic description these days.
> 
> Does anyone have any ideas, please? Does NetworkManager even need full carrier-detection support?

NM needs it if you want the interface to be automatically handled in
0.6.x and earlier.  In 0.7.x and later you'll be able to have NM just
set up the interface even if it doesn't have a link (if you set it to
autoconnect), but of course that means that whenever you start NM the
interface will be up with the settings you specify because, of course,
NM can't automatically figure out when the card is up or down and do
something intelligent.

dan


