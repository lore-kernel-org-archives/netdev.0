From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 11 Apr 2013 16:09:16 +0800
Message-ID: <CACVXFVMxWML6nVNwPLv9RcnVgVNZzUqL8=nf9RaS-KS6Sjqaew@mail.gmail.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1365625850.22411.1.camel@dcbw.foobar.com>
	<CACVXFVNKSszw+3VnM3hwepbTHh3gvjC+pG2SL_OsVm+1SqrNzQ@mail.gmail.com>
	<2552222.23e5DWG2Z9@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dan Williams <dcbw@redhat.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f181.google.com ([209.85.220.181]:60151 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754131Ab3DKIJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 04:09:17 -0400
In-Reply-To: <2552222.23e5DWG2Z9@linux-5eaq.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 11, 2013 at 2:50 PM, Oliver Neukum <oliver@neukum.org> wrote:
> On Thursday 11 April 2013 10:31:31 Ming Lei wrote:
>
>> 'mem_flags' isn't needed any more since we can apply allocation
>> of GFP_NOIO automatically in resume path now, and you can always
>> use GFP_KERNEL safely. Considered that it is a API, please don't
>> introduce it.
>
> The automatic system goes a long way, but there are corner cases, for example
> work queues, which still need mem_flags.

Could you explain why work queue need GFP_NOIO? and the use case for
usbnet?

Thanks,
-- 
Ming Lei
