From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 v4] usbnet: allow status interrupt URB to always be active
Date: Wed, 10 Apr 2013 20:10:11 +0200
Message-ID: <7761183.G42DetJs5Z@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <21345916.cd7DzC6Ttz@linux-5eaq.site> <1365606080.28888.72.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ming Lei <tom.leiming@gmail.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:45662 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935623Ab3DJSJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 14:09:25 -0400
In-Reply-To: <1365606080.28888.72.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 10 April 2013 10:01:20 Dan Williams wrote:
> On Wed, 2013-04-10 at 15:58 +0200, Oliver Neukum wrote:
> > On Wednesday 10 April 2013 08:54:43 Dan Williams wrote:
> > > > The refcounting is very good. Just don't mess around with "force"
> > > 
> > > That's easy to do if the helpers aren't used for suspend/resume, which
> > > is what I had previously in my v2 patches until Ming suggested that I
> > > use the helpers there.  I can go back to that approach if you'd like, it
> > > is a bit less complicated at the expense of sprinkling the interrupt urb
> > > submit/kill code around more widely.
> > 
> > If you introduce a third helper like "forcibly_stop_interrupt" or something,
> > I'll be perfectly happy. Just don't use flags which completely alter behavior.
> > 
> > 	Regards
> > 		Oliver
> 
> Do you mean something more like this?  If so, I'll go ahead and do the
> formal submission.  Thanks!

That looks good and ready.

	Regards
		Oliver
