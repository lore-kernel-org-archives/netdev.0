From: Steve Glendinning <steve@shawell.net>
Subject: Re: smsc95xx: detect chip revision specific features
Date: Tue, 27 Nov 2012 13:21:13 +0000
Message-ID: <CAKh2mn4RQDEfeMGBLm0s1kQtf_m4naKZO0mdV07BegsURzOWFw@mail.gmail.com>
References: <20121126204722.GA26463@elgon.mountain>
	<CAKh2mn4x=0HwUdH8hSbk3fsa16RUBqze_n5XegVjRBsTnT08SA@mail.gmail.com>
	<20121127123957.GT6186@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:35728 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750Ab2K0NVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 08:21:14 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so5094771eek.19
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 05:21:13 -0800 (PST)
In-Reply-To: <20121127123957.GT6186@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> > drivers/net/usb/smsc95xx.c
>> >   1283          if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCAST)) {
>> >   1284                  u32 *filter_mask = kzalloc(32, GFP_KERNEL);
>> >                                                    ^^
>> > We allocate 8 unsigned 32 bit values.  I think this is the mistake here
>> > actually.  It is a typo and should say:

<snip>

On re-reading the datasheet we *do* need 32 u32's here so you were
right the first time!  Patch on its way shortly.

Steve
