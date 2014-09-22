From: Sergiy Lozovsky <sergiy.lozovsky@gmail.com>
Subject: Gneneric Netlink: can two kernel modules register under one family?
Date: Mon, 22 Sep 2014 16:08:43 -0700
Message-ID: <CAK-1WHhvdcP=ChLPgi7AkEzVcWkHow-d3MJZ5jG6HisM6emLpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f179.google.com ([209.85.220.179]:58909 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209AbaIVXIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 19:08:43 -0400
Received: by mail-vc0-f179.google.com with SMTP id la4so4236651vcb.24
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 16:08:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I plan to use Gneneric Netlink as a messaging bus for endpoints of my
system. Endpoints are kernel modules and user space daemons. Generic
Netlink is designed to accommodate multiple user space processes under
one family, but what if I need multiple kernel modules, too? Is it
feasible? Will genl_register_family() work if called for the same
family from two different kernel modules?

Thanks,

Sergiy.
