From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 2/2 v4] sierra_net: keep status interrupt URB active
Date: Wed, 10 Apr 2013 17:01:26 +0200
Message-ID: <4314218.JnQ2dxn9CI@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <4949544.d8fOCnDANj@linux-5eaq.site> <1365605870.28888.70.camel@dcbw.foobar.com>
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
Received: from smtp-out002.kontent.com ([81.88.40.216]:33816 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934984Ab3DJPAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 11:00:41 -0400
In-Reply-To: <1365605870.28888.70.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 10 April 2013 09:57:50 Dan Williams wrote:
> On Wed, 2013-04-10 at 09:15 +0200, Oliver Neukum wrote:
> > On Tuesday 09 April 2013 18:05:51 Dan Williams wrote:
> > > The driver and firmware sync up through SYNC messages, and the
> > > firmware's affirmative reply to these SYNC messages appears to be the
> > > "Reset" indication received via the status interrupt endpoint.  Thus the
> > > driver needs the status interrupt endpoint always active so that the
> > > Reset indication can be received even if the netdev is closed, which is
> > > the case right after device insertion.
> > 
> > WHat about suspend/resume?
> 
> usbnet should take care of that transparently from the sub-drivers
> through it's own suspend/resume logic to kill/resubmit the URB if
> required.  Though is there something I'm missing here?

Sorry, I read mails in antichronological order.

	Regards
		Oliver
