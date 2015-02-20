From: Shahin Ghazinouri <shahin.ghazinouri@gmail.com>
Subject: usbnet devices with several in/out endpoints
Date: Fri, 20 Feb 2015 10:10:59 +0100
Message-ID: <CAM4gwJ3PBCBSK0Rp3pqDP6Rd_vBekfpRtnC=9P1u=Lqb+DjrZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:40410 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753431AbbBTJLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 04:11:00 -0500
Received: by mail-ob0-f179.google.com with SMTP id wp4so22952670obc.10
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 01:10:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm developing a driver for a USB network device that filters received
network packets into two separate USB IN endpoints. This means a
second rx urb has to be allocated and submitted.

Right now, the implementation relies on patching usbnet.c, so that a
second urb is allocated and a new function "rx_submit_fixup" is called
in the device driver. This function is a copy of rx_submit, except it
submits an urb to receive data from the second endpoint.

Would it be feasible to modify the current usbnet framework to support
devices with several endpoints?

Kind regards,
Shahin
