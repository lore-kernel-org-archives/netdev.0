From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: sky2 vs netconsole hard hang
Date: Tue, 27 Jan 2009 15:01:29 +0300
Message-ID: <20090127120129.GA9696@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:52700 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752648AbZA0Lzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 06:55:51 -0500
Received: by ewy14 with SMTP id 14so1554807ewy.13
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 03:55:49 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If sky2 interface is netconsoling, then

	ifconfig down; ifconfig up

leads to hard hang after printing

	sky2 eth0: enabling interface

SysRq+b reboots the box, nothing else works (or prints something).

This is with 2.6.28.2 and 2.6.29-rc2-5ee810072175042775e39bdd3eaaa68884c27805.
Most certainly was there since day one.

Haven't investigated further.
