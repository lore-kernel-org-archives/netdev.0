From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 11 Apr 2013 18:03:09 +0800
Message-ID: <CACVXFVNHoBNpyRztp1Bu_41=YnszqQ3jQDw4j87Zd2hZM3r-VA@mail.gmail.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<2552222.23e5DWG2Z9@linux-5eaq.site>
	<CACVXFVMxWML6nVNwPLv9RcnVgVNZzUqL8=nf9RaS-KS6Sjqaew@mail.gmail.com>
	<3010836.mDNO71IiS7@linux-5eaq.site>
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
Received: from mail-ve0-f177.google.com ([209.85.128.177]:53770 "EHLO
	mail-ve0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752877Ab3DKKDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 06:03:10 -0400
In-Reply-To: <3010836.mDNO71IiS7@linux-5eaq.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 11, 2013 at 5:53 PM, Oliver Neukum <oliver@neukum.org> wrote:
> On Thursday 11 April 2013 16:09:16 Ming Lei wrote:
>>
>> Could you explain why work queue need GFP_NOIO?
>
> Your fix for the memory allocation depends on it happening in the same
> context. If you execute code on a work queue this happens in the context
> of a kernel thread.

I understand the interface might be called from workqueue, and my question
is why GFP_NOIO is needed in the work queue context. Generally speaking,
GFP_KERNEL is enough for work queue context.

As we discussed before, GFP_NOIO is required in runtime resume context
and reset context, and the two contexts have been addressed automatically.
So looks you didn't answer my question, :-)

I mean if GFP_NOIO isn't needed, we can use GFP_KERNEL directly, and
the extra parameter isn't need.

Thanks,
-- 
Ming Lei
