From: Chris Rankin <rankincj@yahoo.com>
Subject: Re: ne driver crashes when unloaded in 2.6.22.6
Date: Sat, 15 Sep 2007 21:27:07 +0100 (BST)
Message-ID: <343200.37246.qm@web52908.mail.re2.yahoo.com>
References: <1189656163.30762.3.camel@xo-3E-67-34.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52908.mail.re2.yahoo.com ([206.190.49.18]:32580 "HELO
	web52908.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750962AbXIOU1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2007 16:27:08 -0400
In-Reply-To: <1189656163.30762.3.camel@xo-3E-67-34.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--- Dan Williams <dcbw@redhat.com> wrote:
> On Wed, 2007-09-12 at 19:23 +0100, Chris Rankin wrote:
> > Hmm, apparently not. The light on the card goes out though, so could this just be a lack of
> driver
> > support?
> 
> Likely, yes.

I've been trawling the Internet for 8390 specifications and have discovered that there is a
"Carrier Sense Loss" flag on the "Transmit Status Register". However, there doesn't seem to be an
explicit "media status" test. Would this more likely be part of the NE2000's functionality? I
can't find any signs of MII support, but then the NE2000 is so heavily cloned that
"NE2000-compatible" seems to have become more of a generic description these days.

Does anyone have any ideas, please? Does NetworkManager even need full carrier-detection support?

Cheers,
Chris



      ___________________________________________________________ 
Want ideas for reducing your carbon footprint? Visit Yahoo! For Good  http://uk.promotions.yahoo.com/forgood/environment.html
