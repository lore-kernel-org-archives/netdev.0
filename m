From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 11 Apr 2013 08:50:30 +0200
Message-ID: <2552222.23e5DWG2Z9@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <1365625850.22411.1.camel@dcbw.foobar.com> <CACVXFVNKSszw+3VnM3hwepbTHh3gvjC+pG2SL_OsVm+1SqrNzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Dan Williams <dcbw@redhat.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:60623 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753893Ab3DKGtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 02:49:46 -0400
In-Reply-To: <CACVXFVNKSszw+3VnM3hwepbTHh3gvjC+pG2SL_OsVm+1SqrNzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 11 April 2013 10:31:31 Ming Lei wrote:
 
> 'mem_flags' isn't needed any more since we can apply allocation
> of GFP_NOIO automatically in resume path now, and you can always
> use GFP_KERNEL safely. Considered that it is a API, please don't
> introduce it.

The automatic system goes a long way, but there are corner cases, for example
work queues, which still need mem_flags.

	Regards
		Oliver
