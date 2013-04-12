From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Fri, 12 Apr 2013 09:28:59 +0200
Message-ID: <39022764.NNhmChWXsk@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <CACVXFVNKSszw+3VnM3hwepbTHh3gvjC+pG2SL_OsVm+1SqrNzQ@mail.gmail.com> <1365694113.22668.4.camel@dcbw.foobar.com>
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
Received: from smtp-out003.kontent.com ([81.88.40.217]:48570 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577Ab3DLH2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 03:28:21 -0400
In-Reply-To: <1365694113.22668.4.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 11 April 2013 10:28:33 Dan Williams wrote:
> > Looks it isn't a good practice to duplicate code in above four functions, but
> > it should be OK to merge first.
> 
> Oliver requested this approach.  I'd originally taken your suggestion to
> merge them, but this proved somewhat more complicated and Oliver
> rejected that approach.

We don't do functions which do a different thing based on flags.
Linus chewed our posteriors for that.

	Regards
		Oliver
