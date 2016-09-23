From: Tim Harvey <tharvey@gateworks.com>
Subject: device-tree support for writing to phy registers?
Date: Fri, 23 Sep 2016 08:40:10 -0700
Message-ID: <CAJ+vNU0sEv_5B-2w-25HtkP1mubbHOYi278prqsDar23Sz80pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33797 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965902AbcIWPkM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 11:40:12 -0400
Received: by mail-io0-f170.google.com with SMTP id e66so32399504iod.1
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 08:40:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings,

I've got a TI DP83867 GbE phy that requires some register writes to
configure its refclock output. Is there a generic device-tree API for
writing to raw registers or is that something that would be need to be
added to a specific phy driver with a device-tree binding? There is a
DP83867 phy driver but it doesn't contain anything related to
configuring its CLKOUT via register 0x170.

Alternatively, is it generally considered 'ok' to take care of this in
the bootloader and not provide the MAC driver the gpio for phy-reset
so that bootloader configuration persists through the kernel?

Regards,

Tim
