From: "Andrew Paprocki" <andrew@ishiboo.com>
Subject: r8169 in 2.6.22 release still not detecting link
Date: Sat, 14 Jul 2007 18:31:29 -0400
Message-ID: <76366b180707141531j28588861n19e2d96dd68d308a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Francois Romieu" <romieu@fr.zoreil.com>, brad@langhorst.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:1401 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764245AbXGNWbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 18:31:31 -0400
Received: by py-out-1112.google.com with SMTP id d32so1547799pye
        for <netdev@vger.kernel.org>; Sat, 14 Jul 2007 15:31:30 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois,

Just writing to let you know that I'm still not getting a link on
either r8169 port with the stock 2.6.22 kernel. I haven't been able to
get any other network interface working on this device yet, as it only
has a mini-PCI slot and I haven't found working wireless hardware yet.
If I had a connection, I'd try to git bisect from the last known
working point (2.6.18), but it is difficult for me to do that given
the current setup.

Do you have any ideas about where I can place some debugging trace? I
seem to always be able to get a link by backing off to the upstream
Realtek driver (6.*). If you suspect any part of the driver, let me
know and I'll put printk()s everywhere possible.

Thanks, -Andrew
