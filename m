From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 0/2] d80211, rt2x00: fixes
Date: Wed, 13 Dec 2006 18:56:57 +0100
Message-ID: <200612131856.58877.IvDoorn@gmail.com>
References: <20061213180032.241265000.midnight@suse.cz> <20061213171205.GB26415@csclub.uwaterloo.ca> <1166031523.4741.0.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:9860 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965062AbWLMR5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 12:57:11 -0500
Received: by nf-out-0910.google.com with SMTP id o25so584429nfa
        for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 09:57:09 -0800 (PST)
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1166031523.4741.0.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 13 December 2006 18:38, Dan Williams wrote:
> On Wed, 2006-12-13 at 12:12 -0500, Lennart Sorensen wrote:
> > On Wed, Dec 13, 2006 at 06:00:35PM +0100, Jiri Benc wrote:
> > > John, in addition to the previous pull request, please also apply the
> > > following two fixes.
> > 
> > What is the state of the rx2x00 driver by now?  I have been playing
> > around with an rt2500 based card, with some success but not enough for
> > me to switch over from wired ethernet yet on my machine.  I used to get
> > lots of hard lockups, but with the latest cvs snapshot in debian's
> > rt2x00-source package, it no longer seems to lockup.  It also now works
> > with WPA without using wpa_supplicant (Yay!  Good work.), it does
> 
> How, by private ioctls?  That's just wrong; I believe you still need to
> go through the 4-way handshake to get the right keying information even
> if you use PSK, which means you still need the supplicant, right?

rt2x00 completely uses the dscape stack, so I am not sure how he is
managing this wpa without wpa_supplicant with rt2x00.
Lennart, are you using rt2x00 or the legacy rt2500 driver?

> > however very frequently pause the transfer, and then after a while (20
> > or 30 seconds probably) it will start moving data again and my transfer
> > will continue.  Is this considered normal for now?  My card happens to
> > be a linksys WMP54G version 4.0.  At least pauses beat crashes.  It's
> > going the right way for a work in progress.
> > 
> > I guess I should go read the bug tracking system and try out newer cvs
> > versions. :)

Ivo
