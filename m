From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 v2] usbnet: allow status interrupt URB to always be active
Date: Wed, 06 Feb 2013 21:19:46 +0100
Message-ID: <15120795.elWxBv0k01@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <1357318096.5370.15.camel@dcbw.foobar.com> <1360175798.11742.12.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Elina Pasheva <epasheva@sierrawireless.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:43756 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755294Ab3BFUTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 15:19:39 -0500
In-Reply-To: <1360175798.11742.12.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 February 2013 12:36:38 Dan Williams wrote:
> Some drivers (ex sierra_net) need the status interrupt URB
> active even when the device is closed, because they receive
> custom indications from firmware.  Allow sub-drivers to set
> a flag that submits the status interrupt URB on probe and
> keeps the URB alive over device open/close.  The URB is still
> killed/re-submitted for suspend/resume, as before.

Given your description in the later patch, which uses this feature,
it seems to me that we can be more efficient if we include infrastructure
to determine whether the interrupt URB is still needed under
some circumstances. Could we put this on hold until we are clear on
the requirements of the protocol?

	Regards
		Oliver
