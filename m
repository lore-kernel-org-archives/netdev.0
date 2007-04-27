From: "Tim Durack" <tdurack@gmail.com>
Subject: Re: r8169 ethernet bonding problems
Date: Fri, 27 Apr 2007 17:44:22 -0400
Message-ID: <9e246b4d0704271444o93dfca0we0203030a0a9fd05@mail.gmail.com>
References: <9e246b4d0704180552q16b05017wd0d7041c3ce04f46@mail.gmail.com>
	 <20070418181333.GA2261@electric-eye.fr.zoreil.com>
	 <9e246b4d0704271353g105ecd62j4f35a6e9027ad590@mail.gmail.com>
	 <12883.1177709449@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Francois Romieu" <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: "Jay Vosburgh" <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.224]:54049 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757218AbXD0VoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 17:44:23 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1032423wxd
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2007 14:44:22 -0700 (PDT)
In-Reply-To: <12883.1177709449@death>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >ip link set dev eth1 promisc on
> >ip link set dev eth2 promisc off

typo, "ip link set dev eth2 promisc on" of course

>
>        From looking at the source code for r8169, but it appears that
> the r8169 driver only reads the device MAC address at probe time, and
> doesn't propogate changes to the MAC out to the device.  That might
> explain the "promisc" problem if the device also does MAC filtering.  Am
> I missing something in the driver?

I have applied all patches from the set, including:

0012-r8169-mac-address-change-support.patch

which I assume adds the ability to reprogram MAC filtering.

Behaviour indicates the MAC filter doesn't get reprogrammed though.

>        I don't actually have one of these to test with, I'm just
> looking at the source and observing that dev_addr is only ever
> referenced in the probe function, and that's only to read in the MAC
> from the device.

You're not missing much, believe me :-|

Tim:>
