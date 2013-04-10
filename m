From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 2/2 v4] sierra_net: keep status interrupt URB active
Date: Wed, 10 Apr 2013 09:15:33 +0200
Message-ID: <4949544.d8fOCnDANj@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <1365548547.23372.2.camel@dcbw.foobar.com> <1365548751.23372.6.camel@dcbw.foobar.com>
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
Received: from smtp-out003.kontent.com ([81.88.40.217]:52330 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755061Ab3DJHPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 03:15:52 -0400
In-Reply-To: <1365548751.23372.6.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 09 April 2013 18:05:51 Dan Williams wrote:
> The driver and firmware sync up through SYNC messages, and the
> firmware's affirmative reply to these SYNC messages appears to be the
> "Reset" indication received via the status interrupt endpoint.  Thus the
> driver needs the status interrupt endpoint always active so that the
> Reset indication can be received even if the netdev is closed, which is
> the case right after device insertion.

WHat about suspend/resume?

	Regards
		Oliver
