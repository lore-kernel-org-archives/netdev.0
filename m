From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 11 Apr 2013 13:08:33 +0200
Message-ID: <87d2u1wci6.fsf@nemi.mork.no>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1365625850.22411.1.camel@dcbw.foobar.com>
	<CACVXFVNKSszw+3VnM3hwepbTHh3gvjC+pG2SL_OsVm+1SqrNzQ@mail.gmail.com>
	<2552222.23e5DWG2Z9@linux-5eaq.site> <87txndwkx1.fsf@nemi.mork.no>
	<CACVXFVMW2Dosr0FAKCvxgUFQKmwbduiC+HqmzS1tsvAHu=G8Kg@mail.gmail.com>
	<87ppy1wfhq.fsf@nemi.mork.no>
	<CACVXFVNn9MQr6JLdin=u642Jb-2ZPfVk8YaBmNdhU0_2e7WJqQ@mail.gmail.com>
	<87hajdwefp.fsf@nemi.mork.no>
	<CACVXFVO+QZ+mtdOFuNuh+8HQOMcuQrKJRAaW9ohyrMCMeZXsjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>, Dan Williams <dcbw@redhat.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:37495 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780Ab3DKLJL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 07:09:11 -0400
In-Reply-To: <CACVXFVO+QZ+mtdOFuNuh+8HQOMcuQrKJRAaW9ohyrMCMeZXsjQ@mail.gmail.com>
	(Ming Lei's message of "Thu, 11 Apr 2013 18:30:19 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ming Lei <tom.leiming@gmail.com> writes:

> OK, I say it again, GFP_KERNEL is enough to cover all cases, and the
> mem_flags parameter is redundant.

The docs for usb_submit_urb() in drivers/usb/core/urb.c lists some
possible mem_flags use cases. Among these are (where (b) and (c) are
cases needing GFP_ATOMIC and not applicable here):

<quote>
 *  (3) If you use a kernel thread with a network driver you must use
 *      GFP_NOIO, unless (b) or (c) apply;
</quote>

Is this example=20
 a) wrong, or
 b) not applicable, or=20
 c) to be excluded from the new API?


Bj=C3=B8rn
